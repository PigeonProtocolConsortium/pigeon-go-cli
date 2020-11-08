require "spec_helper"

RSpec.describe Pigeon::Lexer do
  EXPECTED_TOKENS1 = [
    [:AUTHOR, "USER.3VX92CSQKDK854SYDMESAP6SQKKDMB5Q6XP6HVNETYS064BA0WP0", 65],
    [:DEPTH, 0, 73],
    [:KIND, "nonsense", 87],
    [:PREV, "NONE", 97],
    [:HEADER_END, 98],
    [:BODY_ENTRY, "example", "\"Just block me\"", 122],
    [:BODY_END, 123],
    [:SIGNATURE, "0N0B419YSCHYM82YWGBB6VF0MHHCS0ACGBKD8MYMTGS59XC1T60W2JHKHEW9ZQJW53KTJMVB3MGV3JTFKZWQH9QMAAWG3DE6AQ6SJ30", 237],
    [:MESSAGE_DELIM, 238],
    [:AUTHOR, "USER.3VX92CSQKDK854SYDMESAP6SQKKDMB5Q6XP6HVNETYS064BA0WP0", 303],
    [:DEPTH, 1, 311],
    [:KIND, "unit_test1", 327],
    [:PREV, "TEXT.839FP9NB9E1KFG17SZF49X57B9AYNNX1HQ8DGVE940BPWCRXS82G", 390],
    [:HEADER_END, 391],
    [:BODY_ENTRY, "foo", "\"bar\"", 401],
    [:BODY_END, 402],
    [:SIGNATURE, "7YC6P4AJMPV3JH57JV0AHDP0ZV59WZYKHF49DEM2CJP5ZQCVR4XN6RMS18SBE5S2YXAFG05FA8S3B2YC35CH464822ZQXTCMN2F9G3R", 516],
    [:MESSAGE_DELIM, 517],
    [:AUTHOR, "USER.3VX92CSQKDK854SYDMESAP6SQKKDMB5Q6XP6HVNETYS064BA0WP0", 582],
    [:DEPTH, 2, 590],
    [:KIND, "unit_test2", 606],
    [:PREV, "TEXT.XHHQMFDK1DQSVXQ0XJQDSZQWXF8BNQ1QNRZW4K9V34264MF3WSFG", 669],
    [:HEADER_END, 670],
    [:BODY_ENTRY, "bar", "\"baz\"", 680],
    [:BODY_END, 681],
    [:SIGNATURE, "5YBYC1RSB27WZ00H567RP1YAYBW30PAVHG3ZG55VY2R137YMPZZ0ZMD4T7MJ8RYCMTT72AN4WCN7QAS1NPAPQE134TE8CX7PH2TFM2R", 795],
    [:MESSAGE_DELIM, 796],
    [:AUTHOR, "USER.3VX92CSQKDK854SYDMESAP6SQKKDMB5Q6XP6HVNETYS064BA0WP0", 861],
    [:DEPTH, 3, 869],
    [:KIND, "unit_test3", 885],
    [:PREV, "TEXT.DG0BZ241KY8E60C1F88MTZNEDDBQFZS4EMCNR23VD6Y6RZGNEXSG", 948],
    [:HEADER_END, 949],
    [:BODY_ENTRY, "cats", "\"meow\"", 961],
    [:BODY_END, 962],
    [:SIGNATURE, "QWHA8KHSVFBC0X84VH2F2BS3CSCY58ER4ETXH1WB8SEEMDBS0TBAQHA2HNK1W7VDATBVZHB7EHWNYEN86HYBKK7BBMNSSMR45CEG838", 1076],
    [:MESSAGE_DELIM, 1076],
  ]

  MESSAGE_LINES = [
    "author @VG44QCHKA38E7754RQ5DAFBMMD2CCZQRZ8BR2J4MRHHGVTHGW670",
    "depth 0",
    "kind unit_test",
    "prev NONE",
    "",
    "foo:\"bar\"",
    "",
    "signature hHvhdvUcrabhFPz52GSGa9_iuudOsGEEE7S0o0WJLqjQyhLfgUy72yppHXsG6T4E21p6EEI6B3yRcjfurxegCA==",
  ].freeze

  let(:db) do
    db = Pigeon::Database.new
    db.reset_database
    db
  end

  let(:message) do
    db.delete_current_draft
    db.new_draft(kind: "unit_test")
    db.update_draft("foo", "bar")
    db.publish_draft
  end

  it "tokenizes a bundle" do
    bundle = File.read(NORMAL_PATH + Pigeon::MESSAGE_FILE)
    tokens = Pigeon::Lexer.tokenize(bundle)
    EXPECTED_TOKENS1.each_with_index do |_item, i|
      expect(tokens[i]).to eq(EXPECTED_TOKENS1[i])
    end
  end

  it "tokenizes a single message" do
    string = message.render
    tokens = Pigeon::Lexer.tokenize(string)
    hash = tokens.each_with_object({ BODY: {} }) do |token, h|
      case token.first
      when :HEADER_END, :BODY_END, :MESSAGE_DELIM
        h
      when :BODY_ENTRY
        h[:BODY][token[1]] = token[2]
      else
        h[token.first] = token[1]
      end
    end

    expect(hash[:AUTHOR]).to eq(message.author.multihash)
    expect(hash[:BODY]).to eq(message.body)
    expect(hash[:DEPTH]).to eq(message.depth)
    expect(hash[:KIND]).to eq(message.kind)
    expect(hash[:PREV]).to eq Pigeon::NOTHING
    expect(hash[:SIGNATURE]).to eq(message.signature)
  end
end
