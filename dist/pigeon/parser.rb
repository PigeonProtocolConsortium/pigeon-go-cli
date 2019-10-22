require "strscan"

module Pigeon
  class Token
    attr_reader :kind
    attr_accessor :content

    def initialize(kind)
      @kind = kind
    end
  end

  class Parser
    def initialize(string)
      puts "THIS CLASS IS AN EXPERIMENT"
      puts "I MIGHT DELETE IT LATER."
      @scanner = StringScanner.new(string)
      # @scanner.peek
      # @scanner.scan_until
      # @scanner.getch
    end
  end
end
