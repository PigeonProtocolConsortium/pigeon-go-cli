require "spec_helper"

RSpec.describe Pigeon::Lexer do
  EXPECTED_TOKENS = [
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
  let(:message) do
    draft = Pigeon::Draft.create(kind: "unit_test")
    hash = Pigeon::Storage.current.set_blob(File.read("./logo.png"))
    draft["a"] = "bar"
    draft["b"] = hash
    Pigeon::Message.publish(draft)
  end

  it "tokenizes a bundle" do
    bundle = File.read("./example.bundle")
    tokens = Pigeon::Lexer.tokenize(bundle)
    EXPECTED_TOKENS.each_with_index do |item, i|
      expect(tokens[i]).to eq(EXPECTED_TOKENS[i])
    end
  end

  it "tokenizes a single message" do
    fail([
      "This currently freezes the lexer.",
      "Maybe I need to add a scanner.peek call or sth?",
    ].join(" "))
    tokens = Pigeon::Lexer.tokenize(message.render)
  end
end
