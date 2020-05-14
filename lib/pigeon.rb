require "digest"
require "ed25519"
require "securerandom"
require "set"
require "fileutils"

module Pigeon
  SEED_CONFIG_KEY = "SEED"
  TPL_DIR = File.join(".", "lib", "views")

  PIGEON_DB_PATH = File.join("pigeon.db")
  DEFAULT_BUNDLE_PATH = File.join(Dir.pwd, "bundle")
  DEFAULT_BLOB_DIR = File.join(Dir.home, "pigeon_sha256")
  MESSAGE_FILE = "messages.pgn"
  # MESSAGE TEMPLATE CONSTANTS:
  HEADER_TPL = "author <%= author %>\nkind <%= kind %>\nprev <%= prev %>\ndepth <%= depth %>\nlipmaa <%= lipmaa %>\n\n"
  BODY_TPL = "<% body.to_a.each do |k, v| %><%= k %>:<%= v %><%= \"\\n\" %><% end %>\n"
  FOOTER_TPL = "signature <%= signature %>"
  COMPLETE_TPL = [HEADER_TPL, BODY_TPL, FOOTER_TPL].join("")
  CURRENT_DRAFT = "HEAD.draft"
  NOTHING = "NONE"
  OUTBOX_PATH = File.join(".pgn", "user")
  DRAFT_PLACEHOLDER = "DRAFT"
  CR = "\n"
  BUNDLE_MESSAGE_SEPARATOR = CR * 2
  # /MESSAGE TEMPLATE CONSTANTS

  # Internal namespaces for PStore keys:
  ROOT_NS = ".pgn"
  CONF_NS = "conf"
  PEER_NS = "peers"
  USER_NS = "user"
  BLCK_NS = "blocked"
  MESG_NS = "messages"
  MESSAGE_BY_DEPTH_NS = "messages.by_depth"
  COUNT_INDEX_NS = "messages.count"

  # ^ Internal namespaces for PStore keys

  BLOB_SIGIL = "&"
  MESSAGE_SIGIL = "%"
  IDENTITY_SIGIL = "@"
  STRING_SIGIL = "\""
  IDENTITY_FOOTER = ".ed25519"
  BLOB_FOOTER = ".sha256"
  SIG_FOOTER = ".sig.ed25519"

  # Error messages
  PREV_REQUIRES_SAVE = "Can't fetch `prev` on unsaved messages"
  NO_DRAFT_FOUND = "NO DRAFT FOUND"
  STRING_KEYS_ONLY = "String keys only"
  MISSING_BODY = "BODY CANT BE EMPTY"
  STILL_HAVE_DRAFT = "RESET DRAFT (%s) FIRST (db.delete_current_draft)"
  MISSING_DRAFT = "NO DRAFT. CREATE ONE FIRST. Call db.new_draft(kind, body)"
  RUNAWAY_LOOP = "RUNAWAY LOOP DETECTED"

  # Constants for internal use only:
  FOOTERS_REGEX = Regexp.new("#{SIG_FOOTER}|#{IDENTITY_FOOTER}")
  SIG_RANGE = (SIG_FOOTER.length * -1)..-1
  BLOB_BYTE_LIMIT = 360_000

  class Helpers
    VERFIY_ERROR = "Expected field `%s` to equal %s, got: %s"
    MSG_SIZE_ERROR = "Messages cannot have more than 64 keys. Got %s."

    class VerificationError < StandardError; end
    class MessageSizeError < StandardError; end

    B32_ENC = {
      "00000" => "0", "00001" => "1", "00010" => "2", "00011" => "3",
      "00100" => "4", "00101" => "5", "00110" => "6", "00111" => "7",
      "01000" => "8", "01001" => "9", "01010" => "A", "01011" => "B",
      "01100" => "C", "01101" => "D", "01110" => "E", "01111" => "F",
      "10000" => "G", "10001" => "H", "10010" => "J", "10011" => "K",
      "10100" => "M", "10101" => "N", "10110" => "P", "10111" => "Q",
      "11000" => "R", "11001" => "S", "11010" => "T", "11011" => "V",
      "11100" => "W", "11101" => "X", "11110" => "Y", "11111" => "Z",
    }.freeze

    B32_DEC = {
      "0" => 0b00000, "O" => 0b00000, "1" => 0b00001, "I" => 0b00001,
      "L" => 0b00001, "2" => 0b00010, "3" => 0b00011, "4" => 0b00100,
      "5" => 0b00101, "6" => 0b00110, "7" => 0b00111, "8" => 0b01000,
      "9" => 0b01001, "A" => 0b01010, "B" => 0b01011, "C" => 0b01100,
      "D" => 0b01101, "E" => 0b01110, "F" => 0b01111, "G" => 0b10000,
      "H" => 0b10001, "J" => 0b10010, "K" => 0b10011, "M" => 0b10100,
      "N" => 0b10101, "P" => 0b10110, "Q" => 0b10111, "R" => 0b11000,
      "S" => 0b11001, "T" => 0b11010, "V" => 0b11011, "W" => 0b11100,
      "X" => 0b11101, "Y" => 0b11110, "Z" => 0b11111,
    }.freeze

    def self.lipmaa(n)
      # The original lipmaa function returns -1 for 0
      # but that does not mesh well with our serialization
      # scheme. Comments welcome on this one.
      if n < 1 # Prevent -1, division by zero etc..
        return nil
      end

      m, po3, x = 1, 3, n
      # find k such that (3^k - 1)/2 >= n
      while (m < n)
        po3 *= 3
        m = (po3 - 1) / 2
      end
      po3 /= 3
      # find longest possible backjump
      if (m != n)
        while x != 0
          m = (po3 - 1) / 2
          po3 /= 3
          x %= m
        end
        if (m != po3)
          po3 = m
        end
      end
      result = n - po3
      if result == n - 1
        return nil
      else
        return result
      end
    end

    # http://www.crockford.com/wrmg/base32.html
    def self.b32_encode(string)
      string
        .each_byte
        .to_a
        .map { |x| x.to_s(2).rjust(8, "0") }
        .join
        .scan(/.{1,5}/)
        .map { |x| x.ljust(5, "0") }
        .map { |bits| B32_ENC.fetch(bits) }
        .join
    end

    # http://www.crockford.com/wrmg/base32.html
    def self.b32_decode(string)
      string
        .split("")
        .map { |x| B32_DEC.fetch(x.upcase) }
        .map { |x| x.to_s(2).rjust(5, "0") }
        .join("")
        .scan(/.{1,8}/)
        .map { |x| x.length == 8 ? x.to_i(2).chr : "" }
        .join("")
    end

    def self.verify_string(identity, string_signature, string)
      binary_signature = decode_multihash(string_signature)

      string_key = identity.multihash
      binary_key = decode_multihash(string_key)
      verify_key = Ed25519::VerifyKey.new(binary_key)

      verify_key.verify(binary_signature, string)
    end

    def self.assert(field, actual, expected)
      unless actual == expected
        message = VERFIY_ERROR % [field, actual || "nil", expected || "nil"]
        raise VerificationError, message
      end
    end

    def self.publish_draft(db, draft)
      author = db.who_am_i
      mhash = author.multihash
      template = MessageSerializer.new(draft)
      depth = db.get_message_count_for(mhash)

      draft.author = author
      draft.depth = depth
      draft.prev = db.get_message_by_depth(mhash, depth - 1)
      lpma = Helpers.lipmaa(depth)
      if lpma && draft.prev
        draft.lipmaa = db.get_message_by_depth(mhash, lpma)
      else
        draft.lipmaa = NOTHING
      end

      unsigned = template.render_without_signature
      draft.signature = author.sign(unsigned)
      tokens = Lexer.tokenize_unsigned(unsigned, draft.signature)
      message = Parser.parse(db, tokens)[0]
      db.delete_current_draft
      message
    end

    def self.update_draft(db, key, value)
      draft = db.get_draft
      draft[key] = value
      db._replace_draft(draft)
      return draft.body[key]
    end

    def self.verify_message(db, msg)
      msg_hash = msg.multihash
      body = msg.body
      key_count = body.count
      author = msg.author
      signature = msg.signature

      return db.read_message(msg_hash) if db.have_message?(msg_hash)

      if key_count > 64
        msg = MSG_SIZE_ERROR % key_count
        raise MessageSizeError, msg
      end
      count = db.get_message_count_for(author.multihash)
      expected_prev = db.get_message_by_depth(author.multihash, count - 1) || Pigeon::NOTHING
      assert("depth", count, msg.depth)
      expected_lpma = Helpers.lipmaa(msg.depth)
      if expected_lpma
        real = db.get_message_by_depth(author.multihash, expected_lpma)
        assert("lipmaa", msg.lipmaa, real)
      else
        assert("lipmaa", msg.lipmaa, NOTHING)
      end
      assert("prev", msg.prev, expected_prev)
      tpl = msg.template.render_without_signature
      Helpers.verify_string(author, signature, tpl)
      msg.freeze
      msg
    end

    def self.mkdir_p(path)
      if Dir.exists?(path)
        FileUtils.makedirs(path)
      else
      end
    end

    def self.write_to_disk(base_path, mhash, data)
      p = Helpers.hash2file_path(mhash)
      file_name = p.pop
      Helpers.mkdir_p(base_path)
      dir = p.reduce(base_path) do |accum, item|
        path = File.join(accum, item)
        Helpers.mkdir_p(path)
        path
      end
      full_path = File.join(dir, file_name)
      unless File.file?(full_path)
        FileUtils.makedirs(dir)
        File.write(full_path, data)
      end
    end

    def self.hash2file_path(mhash)
      mhash = mhash.sub(BLOB_SIGIL, "")

      [
        mhash[0...7],
        mhash[7...14],
        mhash[14...21],
        mhash[21...28],
        mhash[28...35],
        mhash[35...42],
        [mhash[42...49], ".", mhash[49...52]].join(""),
      ]
    end

    def self.decode_multihash(string)
      if string[SIG_RANGE] == SIG_FOOTER
        return b32_decode(string.gsub(SIG_FOOTER, ""))
      else
        return b32_decode(string[1..].gsub(FOOTERS_REGEX, ""))
      end
    end
  end
end

require_relative File.join("pigeon", "version.rb")
require_relative File.join("pigeon", "local_identity.rb")
require_relative File.join("pigeon", "remote_identity.rb")
require_relative File.join("pigeon", "storage.rb")
require_relative File.join("pigeon", "message_serializer.rb")
require_relative File.join("pigeon", "draft_serializer.rb")
require_relative File.join("pigeon", "message.rb")
require_relative File.join("pigeon", "draft.rb")
require_relative File.join("pigeon", "lexer.rb")
require_relative File.join("pigeon", "parser.rb")
require_relative File.join("pigeon", "database.rb")
