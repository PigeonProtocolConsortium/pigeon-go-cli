require "spec_helper"

RSpec.describe Pigeon::Lexer do
  it "tokenizes the bundle" do
    Pigeon::Lexer.tokenize(File.read("./example.bundle"))
  end
end
