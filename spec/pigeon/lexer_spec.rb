require "spec_helper"

RSpec.describe Pigeon::Lexer do
  EXPECTED_TOKENS1 = [
    [:AUTHOR, "@DYdgK1KUInVtG3lS45hA1HZ-jTuvfLKsxDpXPFCve04=.ed25519"],
    [:KIND, "scratch_pad"],
    [:PREV, "NONE"],
    [:DEPTH, 0],
    [:HEADER_END],
    [:BODY_ENTRY, "key1", "\"my_value\\n\""],
    [:BODY_ENTRY, "key2", "\"my_value2\""],
    [:BODY_ENTRY, "key3", "\"my_value3\""],
    [:BODY_ENTRY, "key4", "%jvKh9yoiEJaePzoWCF1nnqpIlPgTk9FHEtqczQbvzGM=.sha256"],
    [:BODY_ENTRY, "key5", "&29f3933302c49c60841d7620886ce54afc68630242aee6ff683926d2465e6ca3.sha256"],
    [:BODY_ENTRY, "key6", "@galdahnB3L2DE2cTU0Me54IpIUKVEgKmBwvZVtWJccg=.ed25519"],
    [:BODY_END],
    [:SIGNATURE, "DN7yPTE-m433ND3jBL4oM23XGxBKafjq0Dp9ArBQa_TIGU7DmCxTumieuPBN-NKxlx_0N7-c5zjLb5XXVHYPCQ==.sig.ed25519"],
    [:MESSAGE_END],
    [:AUTHOR, "@DYdgK1KUInVtG3lS45hA1HZ-jTuvfLKsxDpXPFCve04=.ed25519"],
    [:KIND, "second_test"],
    [:PREV, "%ZTBmYWZlMGU0Nzg0ZWZlYjA5NjA0MzdlZWVlNTBiMmY4ODEyZWI1NTZkODcwN2FlMDQxYThmMDExNTNhM2E4NQ==.sha256"],
    [:DEPTH, 1],
    [:HEADER_END],
    [:BODY_ENTRY, "hello", "\"world\""],
    [:BODY_END],
    [:SIGNATURE, "AerpDKbKRrcaM9wihwFsPC4YRAfYWie5XFEKAdnxQom7MTvsXd9W39AvHfljJnEePZpsQVdfq2TtBPoQHc-MCw==.sig.ed25519"],
    [:MESSAGE_END],
  ]

  MESSAGE_LINES = [
    "author @WEf06RUKouNcEVURslzHvepOiK4WbQAgRc_9aiUy7rE=.ed25519",
    "kind unit_test",
    "prev NONE",
    "depth 0",
    "",
    "foo:\"bar\"",
    "",
    "signature hHvhdvUcrabhFPz52GSGa9_iuudOsGEEE7S0o0WJLqjQyhLfgUy72yppHXsG6T4E21p6EEI6B3yRcjfurxegCA==.sig.ed25519",
  ].freeze

  let(:message) do
    draft = Pigeon::Draft.create(kind: "unit_test")
    draft["foo"] = "bar"
    Pigeon::Message.publish(draft)
  end

  before(:each) do
    Pigeon::Storage.reset
    Pigeon::LocalIdentity.reset
  end

  it "tokenizes a bundle" do
    bundle = File.read("./spec/fixtures/normal.bundle")
    tokens = Pigeon::Lexer.tokenize(bundle)
    EXPECTED_TOKENS1.each_with_index do |item, i|
      expect(tokens[i]).to eq(EXPECTED_TOKENS1[i])
    end
  end

  it "tokenizes a single message" do
    string = message.render
    tokens = Pigeon::Lexer.tokenize(string)
    hash = tokens.reduce({ BODY: {} }) do |h, token|
      case token.first
      when :HEADER_END, :BODY_END, :MESSAGE_END
        h
      when :BODY_ENTRY
        h[:BODY][token[1]] = token[2]
      else
        h[token.first] = token.last
      end
      h
    end

    expect(hash[:AUTHOR]).to eq(message.author.public_key)
    expect(hash[:BODY]).to eq(message.body)
    expect(hash[:DEPTH]).to eq(message.depth)
    expect(hash[:KIND]).to eq(message.kind)
    expect(hash[:PREV]).to eq Pigeon::EMPTY_MESSAGE
    expect(hash[:SIGNATURE]).to eq(message.signature)
  end

  it "catches syntax errors" do
    e = Pigeon::Lexer::LexError
    [
      MESSAGE_LINES.dup.insert(3, "@@@").join("\n"),
      MESSAGE_LINES.dup.insert(5, "@@@").join("\n"),
      MESSAGE_LINES.dup.insert(7, "@@@").join("\n"),
    ].map do |bundle|
      expect { Pigeon::Lexer.tokenize(bundle) }.to raise_error(e)
    end
  end
end
