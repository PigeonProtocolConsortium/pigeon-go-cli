require "spec_helper"

RSpec.describe Pigeon::Lexer do
  before(:each) do
    Pigeon::Storage.reset
    Pigeon::LocalIdentity.reset
  end

  let(:tokens) { Pigeon::Lexer.tokenize(File.read("./example.bundle")) }

  it "parses tokens" do
    results = Pigeon::Parser.parse(tokens)
    expect(results.length).to e(2)
  end

  it "crashes on forged messages"
end
