require "spec_helper"

RSpec.describe Pigeon::Lexer do
  EXPECTED_TOKENS1 = [
    [:AUTHOR, "USER.R68Q26P1GEFC0SNVVQ9S29SWCVVRGCYRV7D96GAN3XVQE3F9AZJ0", 65],
    [:DEPTH, 0, 73],
    [:KIND, "unit_test1", 89],
    [:LIPMAA, "NONE", 101],
    [:PREV, "NONE", 111],
    [:HEADER_END, 112],
    [:BODY_ENTRY, "foo", "\"bar\"", 122],
    [:BODY_END, 123],
    [:SIGNATURE,
     "2VMAG4SCX5RHVBKCB1RNZCB0AJN4WN6FEMS7W9FM1CVYSZXMX7CPQFCDPYEKCTGG91Y1YSGY4G5K8XAGQ67HEPDFRMRYQHWQBATAC2R",
     237],
    [:MESSAGE_DELIM, 238],
    [:AUTHOR, "USER.R68Q26P1GEFC0SNVVQ9S29SWCVVRGCYRV7D96GAN3XVQE3F9AZJ0", 303],
    [:DEPTH, 1, 311],
    [:KIND, "unit_test2", 327],
    [:LIPMAA, "NONE", 339],
    [:PREV, "TEXT.6CBA4J3756A5SNM1W1GHNCTT9EG95ZP3ZMAT5Z1EJP7TXMNNVZC0", 402],
    [:HEADER_END, 403],
    [:BODY_ENTRY, "bar", "\"baz\"", 413],
    [:BODY_END, 414],
    [:SIGNATURE,
     "Y34Q47V0BY370RM5KWGRJRN9HFNGJN0C3DEYVB2V2476CW9RN5HD4XD7KMQ6T4T42N36R5P3XX6E3FYEWVZR25AVCF6KQPZHJP6EM10",
     528],
    [:MESSAGE_DELIM, 529],
    [:AUTHOR, "USER.R68Q26P1GEFC0SNVVQ9S29SWCVVRGCYRV7D96GAN3XVQE3F9AZJ0", 594],
    [:DEPTH, 2, 602],
    [:KIND, "unit_test3", 618],
    [:LIPMAA, "NONE", 630],
    [:PREV, "TEXT.5BQZVA8JDC77AVGMF45CMPVHRNXFHQ2C01QJEAR57N6K12JN6PAG", 693],
    [:HEADER_END, 694],
    [:BODY_ENTRY, "cats", "\"meow\"", 706],
    [:BODY_END, 707],
    [:SIGNATURE,
     "W68NWDQB2WTZ8T1RHP5BZA4N1STVKV16K0PXH10MZVR3XTF8HC7T8646X7SAKP5DFZ5K74QEKE3T2K6V0EST50YQQD7FD2PT0H8J62G",
     821],
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

  # it "catches syntax errors" do
  #   e = Pigeon::Lexer::LexError
  #   err_map = {
  #     0 => "Syntax error pos 0 by START field in HEADER",
  #     1 => "Syntax error pos 69 by AUTHOR field in HEADER",
  #     2 => "Syntax error pos 77 by DEPTH field in HEADER",
  #     3 => "Syntax error pos 92 by KIND field in HEADER",
  #     4 => "Syntax error pos 104 by LIPMAA field in HEADER",
  #     5 => "Syntax error pos 114 by PREV field in HEADER",
  #     6 => "Syntax error pos 115 by HEADER_SEPERATOR field in BODY",
  #     7 => "Syntax error pos 125 by A_BODY_ENTRY field in BODY",
  #     8 => "Parse error at 126. Double carriage return not found.",
  #   }
  #   (0..8).to_a.map do |n|
  #     t = MESSAGE_LINES.dup.insert(n, "TEXT.@@").join("\n")
  #     emsg = err_map.fetch(n)
  #     puts "=== #{n}:"
  #     expect { Pigeon::Lexer.tokenize(t) }.to raise_error(e, emsg)
  #   end
  # end
end
