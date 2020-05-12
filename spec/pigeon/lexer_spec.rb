require "spec_helper"

RSpec.describe Pigeon::Lexer do
  EXPECTED_TOKENS1 = [
    [:AUTHOR, "@5W9Z3TB8K8F0D6WKCRYZKRAKRWXN5YXHHNEZ4EYDWBWX0CGY9SZ0.ed25519"],
    [:KIND, "f2461a25-6332-4115-b530-91b9ef26b6a5"],
    [:PREV, "NONE"],
    [:DEPTH, 0],
    [:LIPMAA, "NONE"],
    [:HEADER_END],
    [:BODY_ENTRY, "foo", "\"123\""],
    [:BODY_END],
    [:SIGNATURE, "BSSVYP4STBKGMA0TVRH9PR038Q3T3KXP8ZTADZJV1BWERQ056Y0T1EAA54RYX009CGYP5PZ3VRRQ2HQTMRGY8G2A0WZ3TNB2V733Y0G.sig.ed25519"],
    [:MESSAGE_END],
    [:AUTHOR, "@5W9Z3TB8K8F0D6WKCRYZKRAKRWXN5YXHHNEZ4EYDWBWX0CGY9SZ0.ed25519"],
    [:KIND, "20a21e41-859f-4cec-acb4-56a466b93195"],
    [:PREV, "%R60V14PWNJKG7RKKH04P58SJZKGHR267RTDDHPPGFZ3P98K3HFWG.sha256"],
    [:DEPTH, 1],
    [:LIPMAA, "NONE"],
    [:HEADER_END],
    [:BODY_ENTRY, "foo", "\"123\""],
    [:BODY_END],
    [:SIGNATURE, "JEXF1C0Y6XGPTAT8EB159J8QYKFNY49ZRW07P5B2ESAQ90V2V6WYEF95SN4C05YAZQZ151ZH4WMRP0BXHZVS1400X3BKBGR0HXRT43G.sig.ed25519"],
    [:MESSAGE_END],
    [:AUTHOR, "@5W9Z3TB8K8F0D6WKCRYZKRAKRWXN5YXHHNEZ4EYDWBWX0CGY9SZ0.ed25519"],
    [:KIND, "f4cdc570-b49d-487b-8b55-bc85439f3373"],
    [:PREV, "%VATGV6Q1WXRX330AD6D5PADV84PX2PM9B0BN0CFQY0HWB2DQEGK0.sha256"],
    [:DEPTH, 2],
    [:LIPMAA, "NONE"],
    [:HEADER_END],
    [:BODY_ENTRY, "foo", "\"bar\""],
    [:BODY_END],
    [:SIGNATURE, "4ZVKC8JMY6DPFVXRSE0W8VJZ0KNF1KMZFCT1BENZ80MNY5AMKF7865E9B2EDY1PCG57EYXRTFJY1BXZESDMY0X7R71T5H52Q0CC8C1R.sig.ed25519"],
    [:MESSAGE_END],
    [:AUTHOR, "@5W9Z3TB8K8F0D6WKCRYZKRAKRWXN5YXHHNEZ4EYDWBWX0CGY9SZ0.ed25519"],
    [:KIND, "75630163-0ee1-4e3f-8637-0b72f3e2385c"],
    [:PREV, "%9YF2XH84CA8TSC7NFRVWT5DK8HA67QWTCJBMHYW0W8SX2JXEDN30.sha256"],
    [:DEPTH, 3],
    [:LIPMAA, "NONE"],
    [:HEADER_END],
    [:BODY_ENTRY, "foo", "\"bar\""],
    [:BODY_END],
    [:SIGNATURE, "AXJPY0QFFACTVWCECN4WQKKKBMH9TA47FXS26FN8WZK4ADWCSE4WNGE5Z75CHRP64PQVW5QRT7V8DXET5E006CMZNDRPDMCC9Y2TT1G.sig.ed25519"],
    [:MESSAGE_END],
    [:AUTHOR, "@5W9Z3TB8K8F0D6WKCRYZKRAKRWXN5YXHHNEZ4EYDWBWX0CGY9SZ0.ed25519"],
    [:KIND, "9bf8f1d0-3ce1-4092-ba87-8d019dff05b2"],
    [:PREV, "%ZPR5QZK2FNPCC2XEY4ET1RE7VT3ZE0ZWSY2W4R5DCXPZ7F9C62YG.sha256"],
    [:DEPTH, 4],
    [:LIPMAA, "%VATGV6Q1WXRX330AD6D5PADV84PX2PM9B0BN0CFQY0HWB2DQEGK0.sha256"],
    [:HEADER_END],
    [:BODY_ENTRY, "foo", "\"123\""],
    [:BODY_END],
    [:SIGNATURE, "GXNXBCKNXTE3Z1T6Y3PV6FEWVM3YM3DP86YZRTYFC5AFM4Z2TN5ZKKC0YMT29DZ1X1TJSC3Y5PV6B2RN54ZCKK7ZNPCBA5N6W6WWP38.sig.ed25519"],
    [:MESSAGE_END],
    [:AUTHOR, "@5W9Z3TB8K8F0D6WKCRYZKRAKRWXN5YXHHNEZ4EYDWBWX0CGY9SZ0.ed25519"],
    [:KIND, "c5abeb0a-7a2e-433c-82ea-2e5cb8246cd9"],
    [:PREV, "%9JQ1SDJERFXX5SF049B4Y55MPP2PVYG9BZSZRS2W0BMP26PX0V30.sha256"],
    [:DEPTH, 5],
    [:LIPMAA, "NONE"],
    [:HEADER_END],
    [:BODY_ENTRY, "foo", "\"123\""],
    [:BODY_END],
    [:SIGNATURE, "T20VH1V229ANXB22RJFHWTANKEC9S1ZZEH72A5C3SGRNKH28F0CVR78093YKZXW3645CW0AWFG3FNRYGMBZZ6EC7CMGS3B8NW0J0G28.sig.ed25519"],
    [:MESSAGE_END],
    [:AUTHOR, "@5W9Z3TB8K8F0D6WKCRYZKRAKRWXN5YXHHNEZ4EYDWBWX0CGY9SZ0.ed25519"],
    [:KIND, "e005d271-42c2-4615-bead-131ce0443e44"],
    [:PREV, "%JREA65ZVF9K60STANEWW83YW9XZPHDYTX0BESJTHJAEW7HXW8RF0.sha256"],
    [:DEPTH, 6],
    [:LIPMAA, "NONE"],
    [:HEADER_END],
    [:BODY_ENTRY, "foo", "\"bar\""],
    [:BODY_END],
    [:SIGNATURE, "1S46QAB4RBRN895WWRNDKA3VQ1WS95VEM155X9P8XD1DJ8S0GJBRDJRN5VHNQV5EDMW0APTXQJ28QPPJK3R03K1CH2KV0KF1V5ZA40R.sig.ed25519"],
    [:MESSAGE_END],
    [:AUTHOR, "@5W9Z3TB8K8F0D6WKCRYZKRAKRWXN5YXHHNEZ4EYDWBWX0CGY9SZ0.ed25519"],
    [:KIND, "6fe0bd91-de26-4588-bb23-5950c0b654f4"],
    [:PREV, "%Q8Q5QZDSQW5524QC42WDP8GX4G60RJTN866EDV45C0R33RDJ9770.sha256"],
    [:DEPTH, 7],
    [:LIPMAA, "NONE"],
    [:HEADER_END],
    [:BODY_ENTRY, "foo", "\"bar\""],
    [:BODY_END],
    [:SIGNATURE, "YE2Y4K70BKX1Q7HPBEHH3Y6C4DW577E4AR1CPYF62KXHC81EREFM2TF4JX80CR92J9HJ8JV4CMP7TAB1WF16KA158344W2W59BTDA1G.sig.ed25519"],
    [:MESSAGE_END],
    [:AUTHOR, "@5W9Z3TB8K8F0D6WKCRYZKRAKRWXN5YXHHNEZ4EYDWBWX0CGY9SZ0.ed25519"],
    [:KIND, "8cf7242b-c2ec-4c06-85fc-4294bb9881f9"],
    [:PREV, "%V9K764RRC78D95AT5H7Y1GWN4S9VTFS82YWD0NRYQT51R44DZ630.sha256"],
    [:DEPTH, 8],
    [:LIPMAA, "%9JQ1SDJERFXX5SF049B4Y55MPP2PVYG9BZSZRS2W0BMP26PX0V30.sha256"],
    [:HEADER_END],
    [:BODY_ENTRY, "foo", "\"123\""],
    [:BODY_END],
    [:SIGNATURE, "Q61K5HK1WE03ST965Z9X027WSDGE9PFRBYYQT40T4N582ZN46KJTFC9Z92BZC90QFNY37BZ0ZBH6S86KNV371MNMWG4CT2Q016XT430.sig.ed25519"],
    [:MESSAGE_END],
    [:AUTHOR, "@5W9Z3TB8K8F0D6WKCRYZKRAKRWXN5YXHHNEZ4EYDWBWX0CGY9SZ0.ed25519"],
    [:KIND, "caadfdee-0600-44cf-befd-6332c067a3e7"],
    [:PREV, "%ZRZRSNHAYA10JS3PMNJHNJAQJ1EV1KF9KEATD7JMZ2H78XKFEZXG.sha256"],
    [:DEPTH, 9],
    [:LIPMAA, "NONE"],
    [:HEADER_END],
    [:BODY_ENTRY, "foo", "\"bar\""],
    [:BODY_END],
    [:SIGNATURE, "9TJX6KF51GQNF2J05KPB4V7WZBMKVRV1ECNC6W7ETN4ZQ636DCPH1C95C1W19ZTXMB53TSQK2MW3PFRBKN05C8F8PNY0PG7WG3Q2T30.sig.ed25519"],
    [:MESSAGE_END],
  ].freeze

  MESSAGE_LINES = [
    "author @VG44QCHKA38E7754RQ5DAFBMMD2CCZQRZ8BR2J4MRHHGVTHGW670.ed25519",
    "kind unit_test",
    "prev NONE",
    "depth 0",
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
    bundle = File.read("./spec/fixtures/normal/messages.pgn")
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
      when :HEADER_END, :BODY_END, :MESSAGE_END
        h
      when :BODY_ENTRY
        h[:BODY][token[1]] = token[2]
      else
        h[token.first] = token.last
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
      2 => "Syntax error pos 84 by KIND field in HEADER",
      3 => "Syntax error pos 94 by PREV field in HEADER",
      4 => "Syntax error pos 102 by DEPTH field in HEADER",
      5 => "Syntax error pos 103 by HEADER_SEPERATOR field in BODY",
      6 => "Syntax error pos 113 by A_BODY_ENTRY field in BODY",
      7 => "Parse error at 114. Double carriage return not found.",
    }
    (0..7).to_a.map do |n|
      t = MESSAGE_LINES.dup.insert(n, "@@@").join("\n")
      emsg = err_map.fetch(n)
      expect { Pigeon::Lexer.tokenize(t) }.to raise_error(e, emsg)
    end
  end
end
