require "spec_helper"

RSpec.describe Pigeon::Lexer do
  EXPECTED_TOKENS1 = [
    [:AUTHOR, "@jdiXWunmWiex-dHONMlj7b1HMMFNjbpAj1t9oInbugY=.ed25519"],
    [:KIND, "strings"],
    [:PREV, "NONE"],
    [:DEPTH, 0],
    [:HEADER_END],
    [:BODY_ENTRY, "example_1.1", "\"This is a string.\""],
    [:BODY_ENTRY, "example=_.", "\"A second string.\""],
    [:BODY_END],
    [:SIGNATURE, "hCPIr8xdWIIjtiJp1Sj64v0AgP_ypeDTtZrs8MRHw7w_bMJ7Hx6rSbDOgVUmdIegqD-gEk2WI2S_dUKQ8jg7CQ==.sig.ed25519"],
    [:MESSAGE_END],
    [:AUTHOR, "@jdiXWunmWiex-dHONMlj7b1HMMFNjbpAj1t9oInbugY=.ed25519"],
    [:KIND, "d"],
    [:PREV, "%83td57rcLLFEM7-6HPXDcniwXc4QQo9nyyWn0zhXJGg=.sha256"],
    [:DEPTH, 1],
    [:HEADER_END],
    [:BODY_ENTRY, "e", "&ZGKl9RdLU3Avwlr-Z6j5op9XJhCmW6_v_2J1MVUvCW8=.sha256"],
    [:BODY_END],
    [:SIGNATURE, "FpfdovnJttEZkl-SMO83Nq8gqsfnB4NvtZ4YRdhxKQDK30l1OKpPw5GeFiOEdTJK8WPncq_m0eBHPP84hJ0BDg==.sig.ed25519"],
    [:MESSAGE_END],
    [:AUTHOR, "@jdiXWunmWiex-dHONMlj7b1HMMFNjbpAj1t9oInbugY=.ed25519"],
    [:KIND, "g"],
    [:PREV, "%vVMEqvHHjqubE36olIVStUp-vq0T1e2UsvKdv57kmLU=.sha256"],
    [:DEPTH, 2],
    [:HEADER_END],
    [:BODY_ENTRY, "me_myself_and_i", "@jdiXWunmWiex-dHONMlj7b1HMMFNjbpAj1t9oInbugY=.ed25519"],
    [:BODY_END],
    [:SIGNATURE, "4ARYLytFIcU-TAYoybL3za9cyiTX_5Jt04ueKmPjZVYA6jST6KyQXvUo57MMjfjsdAmXeV-2Nw2Jbx8HaeTqBg==.sig.ed25519"],
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
