require "spec_helper"

RSpec.describe Pigeon::Lexer do
  EXPECTED_TOKENS1 = [
    [:AUTHOR, "@78V80T9Q7862GW5KTNGSDBKMSA53WE98G8TGFDS6HC9HEABFD64G.ed25519"],
    [:KIND, "b049f082-861f-43f0-bc10-ca97b2b91b2e"],
    [:PREV, "NONE"],
    [:DEPTH, 0],
    [:LIPMAA, 0],
    [:HEADER_END],
    [:BODY_ENTRY, "foo", "\"123\""],
    [:BODY_END],
    [:SIGNATURE, "X4KF6YM3YMR457VTJ7HGY92F6W65YQBEG3WS5QDFNSAF45KHMDZZZRWK710F04Y6TPM2AJ3W135RSF42V8DAE7MJSSTCHYP7JQG7E10.sig.ed25519"],
    [:MESSAGE_END],
    [:AUTHOR, "@78V80T9Q7862GW5KTNGSDBKMSA53WE98G8TGFDS6HC9HEABFD64G.ed25519"],
    [:KIND, "bbbae2a3-024b-472d-96b3-8dcc80fcef9e"],
    [:PREV, "%4YDSWA2SWPH28AA1AH40VJBJ1RT8KKXWJFVSZ3FTYW3S2JG7R2EG.sha256"],
    [:DEPTH, 1],
    [:LIPMAA, 0],
    [:HEADER_END],
    [:BODY_ENTRY, "foo", "\"123\""],
    [:BODY_END],
    [:SIGNATURE, "4NACJ81VJTC57W8DBR2JAAEYNGPZ1D08CFXTS66ZF89W5GJHHHH0PMYAQBPWWSMZQWN68XASHAG76605Q0DVWKDW53VYNSQVD05RE38.sig.ed25519"],
    [:MESSAGE_END],
    [:AUTHOR, "@78V80T9Q7862GW5KTNGSDBKMSA53WE98G8TGFDS6HC9HEABFD64G.ed25519"],
    [:KIND, "031a91fd-4c47-41a2-b56a-e6e99bfb4e86"],
    [:PREV, "%510TYAE8EJPWG9JQXGGVBBB8PG2N3BG728R6KZ97Y8YG7K8RGEQG.sha256"],
    [:DEPTH, 2],
    [:LIPMAA, 1],
    [:HEADER_END],
    [:BODY_ENTRY, "foo", "\"bar\""],
    [:BODY_END],
    [:SIGNATURE, "C2PE2DSJVM8NEKSYAN3BZZ4EPM3BYCAX0NHAD2NWS31C2TBAGSJPV1GZXRWKQCP9VV3NAJK0N6F7ZMDC1YPKTEJXKQD57EN61ZVYY08.sig.ed25519"],
    [:MESSAGE_END],
    [:AUTHOR, "@78V80T9Q7862GW5KTNGSDBKMSA53WE98G8TGFDS6HC9HEABFD64G.ed25519"],
    [:KIND, "f4716a10-bb95-4919-8866-fd19188f3457"],
    [:PREV, "%YNKM86MYJC3VN8X6YQV0F7XXX9RTZEEFX5T3KJZ97093GJTWDPQG.sha256"],
    [:DEPTH, 3],
    [:LIPMAA, 2],
    [:HEADER_END],
    [:BODY_ENTRY, "foo", "\"2ab907c7-9a5d-42f1-9ca9-5ac0853daad0\""],
    [:BODY_END],
    [:SIGNATURE, "VXEZG4PWY6DBNMY0A5B8R3FFATN6XFG812V1ZRSZ5VSJ99EKFS7NQN689SP7P4KT8KFM7NQEV3DRDB3XNZ10SZN25ZRPCD14ECFXM1R.sig.ed25519"],
    [:MESSAGE_END],
    [:AUTHOR, "@78V80T9Q7862GW5KTNGSDBKMSA53WE98G8TGFDS6HC9HEABFD64G.ed25519"],
    [:KIND, "617b7d9a-dd39-44a7-afaf-0d5b3651091c"],
    [:PREV, "%X67GBXJ0216VM2AF580T0B6EAMJTQPSYXPYDAKNQTDC7QSG32ZR0.sha256"],
    [:DEPTH, 4],
    [:LIPMAA, 1],
    [:HEADER_END],
    [:BODY_ENTRY, "foo", "\"123\""],
    [:BODY_END],
    [:SIGNATURE, "RX5CPHS5J9BABRKYXCHK59WF9S87SFCVWD2644KYB5BEXX0TAQWT9ZS2MKDW62KRZRX34PRE7NNHB9KHGPFHWDBCB9E2MWNVD5HBG1R.sig.ed25519"],
    [:MESSAGE_END],
    [:AUTHOR, "@78V80T9Q7862GW5KTNGSDBKMSA53WE98G8TGFDS6HC9HEABFD64G.ed25519"],
    [:KIND, "066a62ea-eae0-47ae-8013-401665109dbf"],
    [:PREV, "%F5T6F8K3PFDA2E4QDYP3M5CWF98Y1B46FSVY64BP6YVSNT0AZPV0.sha256"],
    [:DEPTH, 5],
    [:LIPMAA, 4],
    [:HEADER_END],
    [:BODY_ENTRY, "foo", "\"123\""],
    [:BODY_END],
    [:SIGNATURE, "JCPE2X5MPTVR6KKPYYBY9E8MNEG85P2FNMZA342W6HMNAWJ8AQXJF5QX0H6XP3ATR9TBJN4HG7XKFT5W2DZXRW6KZNSG4NV18QT180R.sig.ed25519"],
    [:MESSAGE_END],
    [:AUTHOR, "@78V80T9Q7862GW5KTNGSDBKMSA53WE98G8TGFDS6HC9HEABFD64G.ed25519"],
    [:KIND, "ba16b9f6-a0bc-44e4-b873-da52308186e8"],
    [:PREV, "%KDKK65CX8GMV7EFCJ4K3J77T38SNDE6DX1TE7AKKGW7X74Z63WKG.sha256"],
    [:DEPTH, 6],
    [:LIPMAA, 5],
    [:HEADER_END],
    [:BODY_ENTRY, "foo", "\"bar\""],
    [:BODY_END],
    [:SIGNATURE, "JSSFBAZ58Y73NPWZ912KYS0EZ1WA3V3FAG9VW2TF99B3Z0RH06Q52DS2AEBRPEZJFZWBA1Q4WYR7N19VVGRZ9KDFYAX64PCTA9BEW3G.sig.ed25519"],
    [:MESSAGE_END],
    [:AUTHOR, "@78V80T9Q7862GW5KTNGSDBKMSA53WE98G8TGFDS6HC9HEABFD64G.ed25519"],
    [:KIND, "541368e0-3bbc-4408-a743-c649d88e2547"],
    [:PREV, "%9TVN1WPETZFEDJ49V2B2KFQ7VC58ERWYSJ0SWCFM1A7KBCTYP0X0.sha256"],
    [:DEPTH, 7],
    [:LIPMAA, 6],
    [:HEADER_END],
    [:BODY_ENTRY, "foo", "\"fb97ba07-d037-4550-a5ca-ec63ad91109c\""],
    [:BODY_END],
    [:SIGNATURE, "BFVWMHGZ2Z8GDWGRVJP989DGCR3B4TFNSW6T5VVNS5P0EMFCTXYB583A5V4AVD4DGTWHSGA67N52VP2AS3MEBYM7BQXH4YYAMAK2W1R.sig.ed25519"],
    [:MESSAGE_END],
    [:AUTHOR, "@78V80T9Q7862GW5KTNGSDBKMSA53WE98G8TGFDS6HC9HEABFD64G.ed25519"],
    [:KIND, "c8f2c09f-91f2-48db-b02d-8d9503a7fcd8"],
    [:PREV, "%XFS3B295588XMP91TM50TPGK78WP8KXESSWAG2BHTSZAFCRDDXFG.sha256"],
    [:DEPTH, 8],
    [:LIPMAA, 4],
    [:HEADER_END],
    [:BODY_ENTRY, "foo", "\"a511ac1e-089f-4876-8493-d0d827760515\""],
    [:BODY_END],
    [:SIGNATURE, "YRCG26YGM4TB89K96H6HXZNH0ZXHQB2R8P5FSZ8EHG4GDK1X80BV3GN6S7PW4XNWZPFVDQES4TC5AVRB7D17MF21H86QB58DAKHX210.sig.ed25519"],
    [:MESSAGE_END],
    [:AUTHOR, "@78V80T9Q7862GW5KTNGSDBKMSA53WE98G8TGFDS6HC9HEABFD64G.ed25519"],
    [:KIND, "51c783e4-8729-4e73-9d31-e16db8605004"],
    [:PREV, "%4PE7S4XCCAYPQ42S98K730CEW6ME5HRWJKHHEGYVYPFHSJWXEY1G.sha256"],
    [:DEPTH, 9],
    [:LIPMAA, 8],
    [:HEADER_END],
    [:BODY_ENTRY, "foo", "\"bar\""],
    [:BODY_END],
    [:SIGNATURE, "BBE732XXZ33XTCW1CRA9RG13FQ0FVMR61SAHD621VH8C64B4WA8C86JSTTAHG4CSGNBJJ7YSAVRF3YEBX6GTEB6RRWGDA84VJZPMR3R.sig.ed25519"],
    [:MESSAGE_END],
  ]

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
    Pigeon::Database.new
  end

  let(:message) do
    draft = db.create_draft(kind: "unit_test")
    draft["foo"] = "bar"
    draft.publish
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
      0 => "Syntax error at 0. Failed to read header field.",
      1 => "Syntax error at 69. Failed to read header field.",
      2 => "Syntax error at 84. Failed to read header field.",
      3 => "Syntax error at 94. Failed to read header field.",
      4 => "Syntax error at 102. Failed to read header field.",
      5 => "Syntax error at 103. Failed to read body field.",
      6 => "Syntax error at 113. Failed to read body field.",
      7 => "Parse error at 114. Double carriage return not found.",
    }
    (0..7).to_a.map do |n|
      t = MESSAGE_LINES.dup.insert(n, "@@@").join("\n")
      emsg = err_map.fetch(n)
      expect { Pigeon::Lexer.tokenize(t) }.to raise_error(e, emsg)
    end
  end
end
