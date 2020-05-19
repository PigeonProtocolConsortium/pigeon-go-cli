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
      @loops = 0
    end

    def tokenize
      until scanner.eos?
        safety_check
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
        safety_check
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

    def safety_check
      if @loops > 1000
        raise RUNAWAY_LOOP
      else
        @loops += 1
      end
    end

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

    SYNTAX_ERROR = "Syntax error pos %s by %s field in %s"
    FOOTER_ERROR = "Parse error at %s. Double carriage return not found."

    def flunk!(where)
      msg = SYNTAX_ERROR % [scanner.pos, @last_good, where]
      raise LexError, msg
    end

    def maybe_end_message!
      if tokens.last.last != :MESSAGE_DELIM
        @tokens << [:MESSAGE_DELIM, scanner.pos]
        @last_good = :MESSAGE_DELIM
      end
    end

    CANONICAL_ORDERING = {
      # Current Key => Allowed previous keys
      AUTHOR: [:FOOTER_SEPERATOR, :START],
      DEPTH: [:AUTHOR],
      KIND: [:DEPTH],
      LIPMAA: [:KIND],
      PREV: [:LIPMAA],
      HEADER_SEPERATOR: [:PREV],
    }

    def check_header_order(current)
      expected = CANONICAL_ORDERING.fetch(current)
      if expected.include?(@last_good)
        @last_good = current
      else
        msg = "BAD HEADER ORDERING. Expected: #{expected.join(" OR ")}. Got: #{current}"
        raise msg
      end
    end

    def do_header
      if scanner.scan(AUTHOR)
        author = scanner.matched.chomp.gsub("author ", "")
        @tokens << [:AUTHOR, author, scanner.pos]
        check_header_order(:AUTHOR)
        return
      end

      if scanner.scan(DEPTH)
        depth = scanner.matched.chomp.gsub("depth ", "").to_i
        @tokens << [:DEPTH, depth, scanner.pos]
        check_header_order(:DEPTH)
        return
      end

      if scanner.scan(LIPMAA)
        depth = scanner.matched.chomp.gsub("lipmaa ", "")
        @tokens << [:LIPMAA, depth, scanner.pos]
        check_header_order(:LIPMAA)
        return
      end

      if scanner.scan(PREV)
        prev = scanner.matched.chomp.gsub("prev ", "")
        @tokens << [:PREV, prev, scanner.pos]
        check_header_order(:PREV)
        return
      end

      if scanner.scan(KIND)
        kind = scanner.matched.chomp.gsub("kind ", "")
        @tokens << [:KIND, kind, scanner.pos]
        check_header_order(:KIND)
        return
      end

      if scanner.scan(SEPERATOR)
        @state = BODY
        @tokens << [:HEADER_END, scanner.pos]
        check_header_order(:HEADER_SEPERATOR)
        return
      end

      flunk!(:HEADER)
    end

    def do_body
      if scanner.scan(BODY_ENTRY)
        key, value = scanner.matched.chomp.split(":")
        @tokens << [:BODY_ENTRY, key, value, scanner.pos]
        @last_good = :A_BODY_ENTRY
        return
      end

      if scanner.scan(SEPERATOR)
        @state = FOOTER
        @tokens << [:BODY_END, scanner.pos]
        @last_good = :BODY_SEPERATOR
        return
      end

      flunk!(:BODY)
    end

    def do_footer
      # Reset the lexer to ingest the next entry.
      # If scanner.eos? == true, it will just terminate.

      if scanner.scan(FOOTER_ENTRY)
        sig = scanner.matched.strip.gsub("signature ", "")
        @tokens << [:SIGNATURE, sig, scanner.pos]
        @last_good = :FOOTER_ENTRY
        return
      end

      if scanner.scan(SEPERATOR)
        @state = HEADER
        maybe_end_message!
        @last_good = :FOOTER_SEPERATOR
        @loops = 0
        return
      end

      raise LexError, FOOTER_ERROR % scanner.pos
    end
  end
end
