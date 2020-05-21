require "spec_helper"

RSpec.describe Pigeon::Lexer do
  EXPECTED_TOKENS1 = [
    [:AUTHOR, "@3DWXGXHXCB02WV1TEA47J43HHTTBNMM496ANME7FZ2SYPGA9KTZG.ed25519", 69],
    [:DEPTH, 0, 77],
    [:KIND, "unit_test1", 93],
    [:LIPMAA, "NONE", 105],
    [:PREV, "NONE", 115],
    [:HEADER_END, 116],
    [:BODY_ENTRY, "foo", "\"bar\"", 126],
    [:BODY_END, 127],
    [:SIGNATURE, "2BTX69F6E30BBDNQ0XTT20NCG8C0B393SGQSW5M00G8KF33CAE1YB1MPT760KSTRV2ZJCCNJ883JXEWTTTEEJ8JBHNWEJQFSZ035P0R.sig.ed25519", 253],
    [:MESSAGE_DELIM, 254],
    [:AUTHOR, "@3DWXGXHXCB02WV1TEA47J43HHTTBNMM496ANME7FZ2SYPGA9KTZG.ed25519", 323],
    [:DEPTH, 1, 331],
    [:KIND, "unit_test2", 347],
    [:LIPMAA, "NONE", 359],
    [:PREV, "%RW61BRVRAAM31RFPQ8W6MTYBN840Y898MQ2GTDRSMQES84RPJKHG.sha256", 425],
    [:HEADER_END, 426],
    [:BODY_ENTRY, "bar", "\"baz\"", 436],
    [:BODY_END, 437],
    [:SIGNATURE, "TXC15FZZVK30Q5ZRERFR9VXAJ8KKE58ZGF1JEBNETJN1MHN9EGRQJP7PX99NBZMX177XZWE3M2PCPPF4VBN4J93W2H5FTNJ7K7VG818.sig.ed25519", 563],
    [:MESSAGE_DELIM, 564],
    [:AUTHOR, "@3DWXGXHXCB02WV1TEA47J43HHTTBNMM496ANME7FZ2SYPGA9KTZG.ed25519", 633],
    [:DEPTH, 2, 641],
    [:KIND, "unit_test3", 657],
    [:LIPMAA, "NONE", 669],
    [:PREV, "%CSX0CDPY96DGTGT9V0TNZJ4S84JTSK4AYNE193VXF8AH9ZJHT82G.sha256", 735],
    [:HEADER_END, 736],
    [:BODY_ENTRY, "cats", "\"meow\"", 748],
    [:BODY_END, 749],
    [:SIGNATURE, "91TBR3H90720KGA8FPSSEPHB1R6QGZ0YGTC2T6RT1GBWV9TNR95CWHF0KB4P57RMJQPSC6EA6D5FDN5PC8VM7V8BC32F17V9R9VDR0G.sig.ed25519", 875],
    [:MESSAGE_DELIM, 875],
  ].freeze

  MESSAGE_LINES = [
    "author @VG44QCHKA38E7754RQ5DAFBMMD2CCZQRZ8BR2J4MRHHGVTHGW670.ed25519",
    "depth 0",
    "kind unit_test",
    "lipmaa NONE",
    "prev NONE",
    "",
    "foo:\"bar\"",
    "",
    "signature hHvhdvUcrabhFPz52GSGa9_iuudOsGEEE7S0o0WJLqjQyhLfgUy72yppHXsG6T4E21p6EEI6B3yRcjfurxegCA==.sig.ed25519",
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

  it "catches syntax errors" do
    e = Pigeon::Lexer::LexError
    err_map = {
      0 => "Syntax error pos 0 by START field in HEADER",
      1 => "Syntax error pos 69 by AUTHOR field in HEADER",
      2 => "Syntax error pos 77 by DEPTH field in HEADER",
      3 => "Syntax error pos 92 by KIND field in HEADER",
      4 => "Syntax error pos 104 by LIPMAA field in HEADER",
      5 => "Syntax error pos 114 by PREV field in HEADER",
      6 => "Syntax error pos 115 by HEADER_SEPERATOR field in BODY",
      7 => "Syntax error pos 125 by A_BODY_ENTRY field in BODY",
      8 => "Parse error at 126. Double carriage return not found.",
    }
    (0..8).to_a.map do |n|
      t = MESSAGE_LINES.dup.insert(n, "@@@").join("\n")
      emsg = err_map.fetch(n)
      expect { Pigeon::Lexer.tokenize(t) }.to raise_error(e, emsg)
    end
  end
end
