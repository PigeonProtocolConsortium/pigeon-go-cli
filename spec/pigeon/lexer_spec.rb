require "spec_helper"

RSpec.describe Pigeon::Lexer do
  EXPECTED_TOKENS1 = [
    [:AUTHOR, "USER.Q62ZN46TV1HHYBBD7EFSKWTJQ32PGMYKYXM0GVVM121F8R21RAWG", 65],
    [:DEPTH, 0, 73],
    [:KIND, "unit_test1", 89],
    [:LIPMAA, "NONE", 101],
    [:PREV, "NONE", 111],
    [:HEADER_END, 112],
    [:BODY_ENTRY, "foo", "\"bar\"", 122],
    [:BODY_END, 123],
    [:SIGNATURE, "HAM8XEPCAB81P0A5DQKZ3DQG19Q06KR1G4RZ28CX4EXYCZA1A1MPVBQG540EZQSWHS46W523GJK4K3EWM4C0NWSM7NNG99AMJ70VC1G", 237],
    [:MESSAGE_DELIM, 238],
    [:AUTHOR, "USER.Q62ZN46TV1HHYBBD7EFSKWTJQ32PGMYKYXM0GVVM121F8R21RAWG", 303],
    [:DEPTH, 1, 311],
    [:KIND, "unit_test2", 327],
    [:LIPMAA, "NONE", 339],
    [:PREV, "TEXT.DHSWRP0B9241KZ680WJAHVCVR4C79SH5NN3JCE3HFG9DB51WXC2G", 402],
    [:HEADER_END, 403],
    [:BODY_ENTRY, "bar", "\"baz\"", 413],
    [:BODY_END, 414],
    [:SIGNATURE, "S0CSCTVWQ8R827XP4RNW7MQSQ5AT4EPG0AWF259R4ZWR3C83AZYPARXQXZ9Q32GPKEEWTC9RAKC00A0RTHZCETR712D8T7WVV9RBE18", 528],
    [:MESSAGE_DELIM, 529],
    [:AUTHOR, "USER.Q62ZN46TV1HHYBBD7EFSKWTJQ32PGMYKYXM0GVVM121F8R21RAWG", 594],
    [:DEPTH, 2, 602],
    [:KIND, "unit_test3", 618],
    [:LIPMAA, "NONE", 630],
    [:PREV, "TEXT.8DPH5WX4DWWQ7DF9DBKYMT69Y44XNHHM8W8MV5BNQ7RYRM3W4NSG", 693],
    [:HEADER_END, 694],
    [:BODY_ENTRY, "cats", "\"meow\"", 706],
    [:BODY_END, 707],
    [:SIGNATURE, "G9NC8H0SJGZ6KKQFM6V9VCGVK5FS0MM6B6G1RHJ09EM1ACVQSJPMHBB8YJYPZWXX2EDRD4MMKYEZ6725RAAXYY42KXZC9PPRVVGKR3G", 821],
    [:MESSAGE_DELIM, 821],
  ].freeze

  MESSAGE_LINES = [
    "author @VG44QCHKA38E7754RQ5DAFBMMD2CCZQRZ8BR2J4MRHHGVTHGW670",
    "depth 0",
    "kind unit_test",
    "lipmaa NONE",
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
