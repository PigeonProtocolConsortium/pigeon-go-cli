require "spec_helper"

RSpec.describe Pigeon::Lexer do
  let(:db) do
    db = Pigeon::Database.new
    db.reset_database
    db
  end
  let(:example_bundle) { File.read("./spec/fixtures/normal/#{Pigeon::MESSAGE_FILE}") }
  let(:tokens) { Pigeon::Lexer.tokenize(example_bundle) }

  BAD_TOKENS = [
    [:AUTHOR, "@DYdgK1KUInVtG3lS45hA1HZ-jTuvfLKsxDpXPFCve04=.ed25519"],
    [:KIND, "invalid"],
    [:PREV, "NONE"],
    [:DEPTH, 0],
    [:LIPMAA, Pigeon::Helpers.lipmaa(0)],
    [:HEADER_END],
    [:BODY_ENTRY, "duplicate", "Pigeon does not allow duplicate keys."],
    [:BODY_ENTRY, "duplicate", "This key is a duplicate."],
    [:SIGNATURE, "DN7yPTE-m433ND3jBL4oM23XGxBKafjq0Dp9ArBQa_TIGU7DmCxTumieuPBN-NKxlx_0N7-c5zjLb5XXVHYPCQ==.sig.ed25519"],
    [:MESSAGE_DELIM],
  ].freeze

  it "parses tokens" do
    results = Pigeon::Parser.parse(db, tokens)
    expect(results.length).to eq(3)
    expect(results.first).to be_kind_of(Pigeon::Message)
    expect(results.last).to be_kind_of(Pigeon::Message)
  end

  it "ingests and reconstructs a bundle" do
    messages = db.import_bundle("./spec/fixtures/normal")
    expect(messages.length).to eq(3)
    expect(messages.map(&:class).uniq).to eq([Pigeon::Message])
    re_bundled = messages.map(&:render).join("\n\n") + "\n"
    expect(re_bundled).to eq(example_bundle)
  end

  it "finds duplicate keys" do
    error = Pigeon::Parser::DuplicateKeyError
    expect { Pigeon::Parser.parse(db, BAD_TOKENS) }.to raise_error(error)
  end
end
