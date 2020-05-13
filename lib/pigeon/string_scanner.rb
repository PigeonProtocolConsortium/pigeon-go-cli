module Pigeon
  class StringScanner
    attr_reader :pos, :matched, :string
    MAX_TOKEN_SIZE = 500

    def initialize(string)
      @string = string.freeze
      @pos = 0
      @matched = ""
    end

    def eos?
      result = @pos == @string.length - 1
      puts result ? "is eos" : "not eos"
    end

    def scan(regex)
      puts "Scanning #{regex}"
      @last = regex
      match = regex.match(@string[@pos...MAX_TOKEN_SIZE])
      if match
        length = match.end(0)
        @pos += length
        @matched = match.values_at(0).first
      end
    end
  end
end
