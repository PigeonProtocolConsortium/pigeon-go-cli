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
    [:AUTHOR, "FEED.DYdgK1KUInVtG3lS45hA1HZ-jTuvfLKsxDpXPFCve04="],
    [:KIND, "invalid"],
    [:PREV, "NONE"],
    [:DEPTH, 0],
    [:HEADER_END],
    [:BODY_ENTRY, "duplicate", "Pigeon does not allow duplicate keys."],
    [:BODY_ENTRY, "duplicate", "This key is a duplicate."],
    [:SIGNATURE, "DN7yPTE-m433ND3jBL4oM23XGxBKafjq0Dp9ArBQa_TIGU7DmCxTumieuPBN-NKxlx_0N7-c5zjLb5XXVHYPCQ=="],
    [:MESSAGE_DELIM],
  ].freeze

  it "parses tokens" do
    results = Pigeon::Parser.parse(db, tokens)
    expect(results.length).to eq(4)
    expected_sigs = [
      "0N0B419YSCHYM82YWGBB6VF0MHHCS0ACGBKD8MYMTGS59XC1T60W2JHKHEW9ZQJW53KTJMVB3MGV3JTFKZWQH9QMAAWG3DE6AQ6SJ30",
      "7YC6P4AJMPV3JH57JV0AHDP0ZV59WZYKHF49DEM2CJP5ZQCVR4XN6RMS18SBE5S2YXAFG05FA8S3B2YC35CH464822ZQXTCMN2F9G3R",
      "5YBYC1RSB27WZ00H567RP1YAYBW30PAVHG3ZG55VY2R137YMPZZ0ZMD4T7MJ8RYCMTT72AN4WCN7QAS1NPAPQE134TE8CX7PH2TFM2R",
      "QWHA8KHSVFBC0X84VH2F2BS3CSCY58ER4ETXH1WB8SEEMDBS0TBAQHA2HNK1W7VDATBVZHB7EHWNYEN86HYBKK7BBMNSSMR45CEG838",
    ].sort
    actual_sigs = results.map { |x| x.signature }.sort
    expect(actual_sigs - expected_sigs).to eq([])
    expect(results.first).to be_kind_of(Pigeon::Message)
    expect(results.last).to be_kind_of(Pigeon::Message)
  end

  it "ingests and reconstructs a bundle" do
    messages = db.import_bundle("./spec/fixtures/normal")
    expect(messages.length).to eq(4)
    expect(messages.map(&:class).uniq).to eq([Pigeon::Message])
    re_bundled = messages.map(&:render).join("\n\n") + "\n"
    expect(re_bundled).to eq(example_bundle)
  end

  it "finds duplicate keys" do
    error = Pigeon::Parser::DuplicateKeyError
    expect { Pigeon::Parser.parse(db, BAD_TOKENS) }.to raise_error(error)
  end
end
