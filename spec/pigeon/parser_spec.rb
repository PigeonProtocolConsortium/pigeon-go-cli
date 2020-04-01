require "spec_helper"

RSpec.describe Pigeon::Lexer do
  before(:each) do
    Pigeon::Storage.reset
    Pigeon::LocalIdentity.reset
  end

  let(:example_bundle) { File.read("./spec/fixtures/normal.bundle") }
  let(:tokens) { Pigeon::Lexer.tokenize(example_bundle) }

  it "parses tokens" do
    results = Pigeon::Parser.parse(tokens)
    expect(results.length).to eq(2)
    expect(results.first).to be_kind_of(Pigeon::Message)
    expect(results.last).to be_kind_of(Pigeon::Message)
  end

  it "ingests and reconstructs a bundle" do
    pending("Pigeon::Bundle.ingest is broke. Will fix after investigation.")
    messages = Pigeon::Bundle.ingest("./spec/fixtures/normal.bundle")
    expect(messages.length).to eq(2)
    expect(messages.map(&:class).uniq).to eq([Pigeon::Message])
    re_bundled = messages.map(&:render).join("\n\n") + "\n"
    expect(re_bundled).to eq(example_bundle)
  end
end
