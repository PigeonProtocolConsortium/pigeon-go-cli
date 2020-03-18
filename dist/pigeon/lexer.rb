module Pigeon
  class Lexer
    attr_reader :bundle_string, :scanner, :tokens
    # TODO: Change all the `{40,90}` values in ::Lexer to real values
    # TODO: Create regexes using string and Regexp.new() for cleaner regexes.
    FEED_VALUE = /@.{40,90}.ed25519/
    DEPTH_COUNT = /\d{1,7}/
    MESG_VALUE = /%.{40,90}.sha256/
    BLOB_VALUE = /&.{40,90}.sha256/
    NULL_VALUE = /NONE/
    STRG_VALUE = /".{1,64}"/
    ALPHANUMERICISH = /[a-zA-Z\d\.]{1,64}/
    ALL_VALUES = [
      FEED_VALUE,
      MESG_VALUE,
      NULL_VALUE,
      STRG_VALUE,
      BLOB_VALUE,
    ].map(&:source).join("|")
    ANY_VALUE = Regexp.new(ALL_VALUES)

    SEPERATOR = /\n\n/
    AUTHOR = /author #{FEED_VALUE}/
    DEPTH = /depth #{DEPTH_COUNT}/
    PREV = /prev (#{MESG_VALUE}|#{NULL_VALUE})/
    KIND = /kind #{ALPHANUMERICISH}/
    BODY_ENTRY = /#{ALPHANUMERICISH}:#{ANY_VALUE}\n/

    FOOTER_ENTRY = /signature .*{40,90}\.sig\.ed25519/

    LEXER_STATES = [HEADER = :header, BODY = :body, FOOTER = :footer]

    def self.tokenize(bundle_string)
      # TODO: Maybe move #tokeinze into constructor.
      new(bundle_string).tokenize
    end

    def initialize(bundle_string)
      @bundle_string = bundle_string
      @scanner = StringScanner.new(bundle_string)
      @tokens = []
    end

    def stack
      @stack ||= []
    end

    def state
      stack.last || :header
    end

    def push_state(state)
      stack.push(state)
    end

    def pop_state
      stack.pop
    end

    def scan_header(scanner)
    end

    def do_header
      if scanner.scan(WHATEVER)
        tokens << [:OPEN_BLOCK]
        push_state :expression
        return
      end

      if scanner.scan_until(/.*?(?={{)/m)
        tokens << [:CONTENT, scanner.matched]
      else
        tokens << [:CONTENT, scanner.rest]
        scanner.terminate
      end
    end

    def tokenize
      until scanner.eos?
        case state
        when HEADER
          raise "WIP"
        when BODY
          raise "WIP"
        when FOOTER
          raise "WIP"
        end
      end
    end
  end
end
