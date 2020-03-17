module Pigeon
  class Bundle
    class Lexer
      # No *_VALUE can be > 128 chars.
      MAX_CHUNK_SIZE = 128
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

      FOOTER = /signature .*{40,90}\.sig\.ed25519/

      def self.tokenize(bundle_string)
        new.tokenize(bundle_string)
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

      def tokenize(bundle_string)
        scanner = StringScanner.new(bundle_string)
        tokens = []
        until scanner.eos?
          case state
          when :header
            raise "WIP"
          else
            raise "Bad state?"
          end
        end
      end
    end

    def self.create(file_path = DEFAULT_BUNDLE_PATH)
      s = Pigeon::Storage.current
      last = s.message_count
      author = Pigeon::KeyPair.current
      range = (0...last).to_a
      content = range
        .map { |depth| s.get_message_by_depth(author, depth) }
        .map { |multihash| s.find_message(multihash) }
        .map { |message| message.render }
        .join(BUNDLE_MESSAGE_SEPARATOR)
      File.write(file_path, content + CR)
    end

    def self.ingest(file_path)
    end

    private

    class Parser
    end

    class Interpreter
    end

    def initialize
    end
  end
end
