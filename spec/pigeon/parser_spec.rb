require "spec_helper"

RSpec.describe Pigeon::Lexer do
  before(:each) do
    Pigeon::Storage.reset
    Pigeon::LocalIdentity.reset
  end

  let(:tokens) { Pigeon::Lexer.tokenize(File.read("./example.bundle")) }

  it "parses tokens" do
    results = Pigeon::Parser.parse(tokens)
    expect(results.length).to eq(2)
    expect(results.first).to be_kind_of(Pigeon::Message)
    expect(results.last).to be_kind_of(Pigeon::Message)
  end

  it "crashes on forged messages"
end
