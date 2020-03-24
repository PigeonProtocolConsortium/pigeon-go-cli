module Pigeon
  class Parser
    def self.parse(tokens)
      self.new(tokens).parse
    end

    def initialize(tokens)
      @scratchpad = {}
      @tokens = tokens
      @results = []
    end

    def parse()
    end

    private

    def collect_tokens
    end

    def validate_message
    end
  end
end
