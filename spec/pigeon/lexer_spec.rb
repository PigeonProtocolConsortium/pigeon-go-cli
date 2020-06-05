require "spec_helper"

RSpec.describe Pigeon::Lexer do
  EXPECTED_TOKENS1 = [
    [:AUTHOR, "USER.5A0C0E9G6AVQV8F95TJ4Q695FF4XKDAYCJP7Y054A6MD8SZ9SHS0", 65],
    [:DEPTH, 0, 73],
    [:KIND, "unit_test1", 89],
    [:LIPMAA, "NONE", 101],
    [:PREV, "NONE", 111],
    [:HEADER_END, 112],
    [:BODY_ENTRY, "foo", "\"bar\"", 122],
    [:BODY_END, 123],
    [:SIGNATURE,
     "ATSBRW327KYD7XCTCSAVAAMZF1WK5AJQB6NVRVXTB3CYCWFQ56KCG1WA6D4H0D9Y1EB4ZDEA11E87WNM7DZPZ1JJ4Z2BZ1BFF9JMA0G",
     237],
    [:MESSAGE_DELIM, 238],
    [:AUTHOR, "USER.5A0C0E9G6AVQV8F95TJ4Q695FF4XKDAYCJP7Y054A6MD8SZ9SHS0", 303],
    [:DEPTH, 1, 311],
    [:KIND, "unit_test2", 327],
    [:LIPMAA, "NONE", 339],
    [:PREV, "TEXT.HPD1SBZGWMT3G35MMY7BVPQRXX1NDAVWHCB45KGFXFRKG85AXXX0", 402],
    [:HEADER_END, 403],
    [:BODY_ENTRY, "bar", "\"baz\"", 413],
    [:BODY_END, 414],
    [:SIGNATURE,
     "J8A9YWQ7SXZ8BCYYKS619SZBF4JGT3PJBWJYCY8RZ4Y2ZCHF5MAZGD3773YNXV87EPTJ2BFSSDWBNEK7B410ATS07RQ70G3PVZQNM18",
     528],
    [:MESSAGE_DELIM, 529],
    [:AUTHOR, "USER.5A0C0E9G6AVQV8F95TJ4Q695FF4XKDAYCJP7Y054A6MD8SZ9SHS0", 594],
    [:DEPTH, 2, 602],
    [:KIND, "unit_test3", 618],
    [:LIPMAA, "NONE", 630],
    [:PREV, "TEXT.BPNKG8F5W0J7N7WZB0V204BM709BKH3ASFNRGZN0JCSKBMM9WN7G", 693],
    [:HEADER_END, 694],
    [:BODY_ENTRY, "cats", "\"meow\"", 706],
    [:BODY_END, 707],
    [:SIGNATURE,
     "YC0RPJYDNWKAW17NY5FH00QXK1P4ZN2DKN1XJT5BZHY7XR2YRN3WA9Q5Q3MSH3NSDF18SGXTXVETGWQ8M8BFQNG20W6H4QEVPWPC000",
     821],
    [:MESSAGE_DELIM, 822],
    [:AUTHOR, "USER.5A0C0E9G6AVQV8F95TJ4Q695FF4XKDAYCJP7Y054A6MD8SZ9SHS0", 887],
    [:DEPTH, 3, 895],
    [:KIND, "unit_test1", 911],
    [:LIPMAA, "NONE", 923],
    [:PREV, "TEXT.5NVP47TNZADV5FJ8MRRK053RABR5M25WHPS6PX0WF9SHW2DFX9K0", 986],
    [:HEADER_END, 987],
    [:BODY_ENTRY, "foo", "\"bar\"", 997],
    [:BODY_END, 998],
    [:SIGNATURE,
     "D90N2YVS609GHCPYPBC4YZ7DPYHXMN41V6S9CFZH015VXBTM19RPEME3ZYXD6QGRE9D50HPZED6SS68MCW90HVXNWYDQ28ZZZVZX61R",
     1112],
    [:MESSAGE_DELIM, 1113],
    [:AUTHOR, "USER.5A0C0E9G6AVQV8F95TJ4Q695FF4XKDAYCJP7Y054A6MD8SZ9SHS0", 1178],
    [:DEPTH, 4, 1186],
    [:KIND, "unit_test2", 1202],
    [:LIPMAA, "TEXT.BPNKG8F5W0J7N7WZB0V204BM709BKH3ASFNRGZN0JCSKBMM9WN7G", 1267],
    [:PREV, "TEXT.B73NKGM8223BQNMMGQFWM6696H0S09370P1R83DV6ZHCCHJTHXBG", 1330],
    [:HEADER_END, 1331],
    [:BODY_ENTRY, "bar", "\"baz\"", 1341],
    [:BODY_END, 1342],
    [:SIGNATURE,
     "8Y0FGEHT4EXS7KDHKY1CA2Y7ANECWF0KA79TPFVNGYXKZCD4DTCPCDKX63SQ82ZQEYBGHMW7SH28Q6356ADM59RKTVHZN4AVM1SD418",
     1456],
    [:MESSAGE_DELIM, 1457],
    [:AUTHOR, "USER.5A0C0E9G6AVQV8F95TJ4Q695FF4XKDAYCJP7Y054A6MD8SZ9SHS0", 1522],
    [:DEPTH, 5, 1530],
    [:KIND, "unit_test3", 1546],
    [:LIPMAA, "NONE", 1558],
    [:PREV, "TEXT.XHB77EVS0SAQDMSVG1N2DVMWNTAZJSF1FZ3921EW16F4AGHFYQEG", 1621],
    [:HEADER_END, 1622],
    [:BODY_ENTRY, "cats", "\"meow\"", 1634],
    [:BODY_END, 1635],
    [:SIGNATURE,
     "TSR3AEFJA45E6GCCWRD5A4DKQMZQYQPRP5WV38YB5AP9VVEPCWDDJ0HJCE2WFAEXQKNYV5FKZJ2RMWNSYQ9C3P8K1DV5NRVANT6SR28",
     1749],
    [:MESSAGE_DELIM, 1749],
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
      t = MESSAGE_LINES.dup.insert(n, "TEXT.@@").join("\n")
      emsg = err_map.fetch(n)
      expect { Pigeon::Lexer.tokenize(t) }.to raise_error(e, emsg)
    end
  end
end
