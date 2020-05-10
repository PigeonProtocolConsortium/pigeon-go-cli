module Pigeon
  class Lexer
    def self.tokenize(bundle_string)
      new(bundle_string).tokenize
    end

    def self.tokenize_unsigned(bundle_string, signature)
      new(bundle_string).tokenize_unsigned(signature)
    end

    def initialize(bundle_string)
      @bundle_string = bundle_string
      @scanner = StringScanner.new(bundle_string)
      @tokens = []
      @state = HEADER
      @last_good = :START
    end

    def tokenize
      until scanner.eos?
        case @state
        when HEADER then do_header
        when BODY then do_body
        when FOOTER then do_footer
        end
      end
      maybe_end_message!
      return tokens
    end

    def tokenize_unsigned(signature)
      until scanner.eos?
        case @state
        when HEADER then do_header
        when BODY then do_body
        end
      end
      tokens << [:SIGNATURE, signature]
      maybe_end_message!
      return tokens
    end

    private

    attr_reader :bundle_string, :scanner, :tokens
    # TODO: Change all the `{40,90}` values in ::Lexer to real values
    # TODO: Create regexes using string and Regexp.new() for cleaner regexes.
    NUMERIC = /\d{1,7}/
    NULL_VALUE = /NONE/
    FEED_VALUE = /@.{52}\.ed25519/
    MESG_VALUE = /%.{52}\.sha256/
    BLOB_VALUE = /&.{52}\.sha256/
    STRG_VALUE = /".{1,128}"/
    # If you need other characters (but not spaces) submit an issue.
    ALPHANUMERICISH = /[a-zA-Z0-9_\-=\.\@\&]{1,90}/
    ALL_VALUES = [
      FEED_VALUE,
      MESG_VALUE,
      NULL_VALUE,
      STRG_VALUE,
      BLOB_VALUE,
    ].map(&:source).join("|")
    ANY_VALUE = Regexp.new(ALL_VALUES)

    SEPERATOR = /\n/
    AUTHOR = /author #{FEED_VALUE}\n/
    DEPTH = /depth #{NUMERIC}\n/
    LIPMAA = /lipmaa (#{MESG_VALUE}|#{NULL_VALUE})\n/
    PREV = /prev (#{MESG_VALUE}|#{NULL_VALUE})\n/
    KIND = /kind #{ALPHANUMERICISH}\n/
    BODY_ENTRY = /#{ALPHANUMERICISH}:#{ANY_VALUE}\n/
    FOOTER_ENTRY = /signature .*{103}\.sig\.ed25519\n?/

    LEXER_STATES = [HEADER = :header, BODY = :body, FOOTER = :footer]

    class LexError < StandardError; end

    def flunk!(why)
      raise LexError, "Syntax error @ #{scanner.pos} after #{@last_good}: #{why}"
    end

    # This might be a mistake or uneccessary. NN 20 MAR 2020
    def maybe_end_message!
      if tokens.last.last != :MESSAGE_END
        @tokens << [:MESSAGE_END]
        @last_good = :MESSAGE_END
      end
    end

    def do_header
      if scanner.scan(AUTHOR)
        author = scanner.matched.chomp.gsub("author ", "")
        @tokens << [:AUTHOR, author]
        @last_good = :AUTHOR
        return
      end

      if scanner.scan(DEPTH)
        depth = scanner.matched.chomp.gsub("depth ", "").to_i
        @tokens << [:DEPTH, depth]
        @last_good = :DEPTH
        return
      end

      if scanner.scan(LIPMAA)
        depth = scanner.matched.chomp.gsub("lipmaa ", "").to_i
        @tokens << [:LIPMAA, depth]
        @last_good = :LIPMAA
        return
      end

      if scanner.scan(PREV)
        prev = scanner.matched.chomp.gsub("prev ", "")
        @tokens << [:PREV, prev]
        @last_good = :PREV
        return
      end

      if scanner.scan(KIND)
        kind = scanner.matched.chomp.gsub("kind ", "")
        @tokens << [:KIND, kind]
        @last_good = :KIND
        return
      end

      if scanner.scan(SEPERATOR)
        @state = BODY
        @tokens << [:HEADER_END]
        @last_good = :HEADER_SEPERATOR
        return
      end

      flunk!("Failed to read header field.")
    end

    def do_body
      if scanner.scan(BODY_ENTRY)
        key, value = scanner.matched.chomp.split(":")
        @tokens << [:BODY_ENTRY, key, value]
        @last_good = :A_BODY_ENTRY
        return
      end

      if scanner.scan(SEPERATOR)
        @state = FOOTER
        @tokens << [:BODY_END]
        @last_good = :BODY_SEPERATOR
        return
      end

      flunk!("Failed to read body field.")
    end

    def do_footer
      # Reset the lexer to ingest the next entry.
      # If scanner.eos? == true, it will just terminate.

      if scanner.scan(FOOTER_ENTRY)
        sig = scanner.matched.strip.gsub("signature ", "")
        @tokens << [:SIGNATURE, sig]
        @last_good = :FOOTER_ENTRY
        return
      end

      if scanner.scan(SEPERATOR)
        @state = HEADER
        maybe_end_message!
        @last_good = :FOOTER_SEPERATOR
        return
      end

      raise LexError, "Parse error at #{scanner.pos}. Double carriage return not found."
    end
  end
end
