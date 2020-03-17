require "spec_helper"

RSpec.describe Pigeon::Bundle::Lexer do
  it "tokenizes the bundle" do
    Pigeon::Bundle::Lexer.tokenize(File.read("./example.bundle"))
  end
end
