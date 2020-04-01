module Pigeon
  class Lexer
    attr_reader :bundle_string, :scanner, :tokens
    # TODO: Change all the `{40,90}` values in ::Lexer to real values
    # TODO: Create regexes using string and Regexp.new() for cleaner regexes.
    FEED_VALUE = /@.{43,45}.ed25519/
    DEPTH_COUNT = /\d{1,7}/
    MESG_VALUE = /%.{40,90}.sha256/
    BLOB_VALUE = /&.{40,90}.sha256/
    NULL_VALUE = /NONE/
    STRG_VALUE = /".{1,64}"/
    ALPHANUMERICISH = /[a-zA-Z\d\._]{1,64}/
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
    DEPTH = /depth #{DEPTH_COUNT}\n/
    PREV = /prev (#{MESG_VALUE}|#{NULL_VALUE})\n/
    KIND = /kind #{ALPHANUMERICISH}\n/
    BODY_ENTRY = /#{ALPHANUMERICISH}:#{ANY_VALUE}\n/

    FOOTER_ENTRY = /signature .*{87,88}\.sig\.ed25519\n?/

    LEXER_STATES = [HEADER = :header, BODY = :body, FOOTER = :footer]

    class LexError < StandardError; end

    def self.tokenize(bundle_string)
      new(bundle_string).tokenize
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

    private

    def initialize(bundle_string)
      @bundle_string = bundle_string
      @scanner = StringScanner.new(bundle_string)
      @tokens = []
      @state = HEADER
    end

    def flunk!(why)
      raise LexError, "Syntax error at #{scanner.pos}. #{why}"
    end

    # This might be a mistake or uneccessary. NN 20 MAR 2020
    def maybe_end_message!
      unless tokens.last.last == :MESSAGE_END
        @tokens << [:MESSAGE_END]
      end
    end

    def do_header
      if scanner.scan(AUTHOR)
        author = scanner.matched.chomp.gsub("author ", "")
        @tokens << [:AUTHOR, author]
        return
      end

      if scanner.scan(DEPTH)
        depth = scanner.matched.chomp.gsub("depth ", "").to_i
        @tokens << [:DEPTH, depth]
        return
      end

      if scanner.scan(PREV)
        prev = scanner.matched.chomp.gsub("prev ", "")
        @tokens << [:PREV, prev]
        return
      end

      if scanner.scan(KIND)
        kind = scanner.matched.chomp.gsub("kind ", "")
        @tokens << [:KIND, kind]
        return
      end

      if scanner.scan(SEPERATOR)
        @state = BODY
        @tokens << [:HEADER_END]
        return
      end

      flunk!("Failed to read header field.")
    end

    def do_body
      if scanner.scan(BODY_ENTRY)
        key, value = scanner.matched.chomp.split(":")
        @tokens << [:BODY_ENTRY, key, value]
        return
      end

      if scanner.scan(SEPERATOR)
        @state = FOOTER
        @tokens << [:BODY_END]
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
        return
      end

      if scanner.scan(SEPERATOR)
        @state = HEADER
        maybe_end_message!
        return
      end

      raise LexError, "Parse error at #{scanner.pos}. Double carriage return not found."
    end
  end
end
