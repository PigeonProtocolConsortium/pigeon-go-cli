module Pigeon
  class Parser
    class DuplicateKeyError < StandardError; end

    def self.parse(tokens)
      self.new(tokens).parse
    end

    def initialize(tokens)
      @scratchpad = {}
      @tokens = tokens
      @results = []
    end

    def parse()
      @tokens.each_with_index do |token, i|
        case token.first
        when :AUTHOR then set(:author, token.last)
        when :KIND then set(:kind, token.last)
        when :DEPTH then set(:depth, token.last)
        when :PREV then set(:prev, token.last)
        when :HEADER_END then set(:body, {})
        when :BODY_ENTRY then set(token[1], token[2], @scratchpad[:body])
        when :BODY_END then nil
        when :SIGNATURE then set(:signature, token.last)
        when :MESSAGE_END then finish_this_message!
        end
      end
      @results
    end

    private

    def finish_this_message!
      @scratchpad.freeze
      @results.push(Message.ingest(**@scratchpad))
      @scratchpad = {}
    end

    def set(key, value, hash = @scratchpad)
      if hash[key]
        raise DuplicateKeyError, "Found duplicate keys: #{key}"
      else
        hash[key] = value
      end
    end
  end
end
