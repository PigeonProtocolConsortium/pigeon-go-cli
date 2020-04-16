require "spec_helper"

RSpec.describe Pigeon::LocalIdentity do
  FAKE_SEED = "\x15\xB1\xA8\x1D\xE1\x1Cx\xF0" \
  "\xC6\xDCK\xDE\x9A\xB7>\x86o\x92\xEF\xB7\x17" \
  ")\xFF\x01E\b$b)\xC9\x82\b"
  let(:kp) { Pigeon::LocalIdentity.new(FAKE_SEED) }

  HELLO_SIGNATURE = [
    "FARSW9ENM9DK1JD4M9ES1D4WWVG5SXT8Z6VXT6HXRV17M4Q9X5W2",
    "T5Y7ZZC0C5JYBTMBQ2HAQBRGWGAK42PK3BHQXAX1FPTKBFJQJ1R",
    ".sig.ed25519",
  ].join("")
  it "signs arbitrary data" do
    expect(kp.sign("hello")).to eq(HELLO_SIGNATURE)
  end

  it "generates a pair from a seed" do
    x = "@XSZY1ME6QMA5BBSJ8QSDJCSG6EVDTCKYNMV221SB7B2NZR5K09J0.ed25519"
    expect(kp.multihash).to eq(x)
    y = "2PRTG7F13HWF1HPW9FF9NDSYGSQS5VXQ2WMZY0A510J64AE9G840"
    expect(kp.private_key).to eq(y)
  end

  it "strips headers" do
    whatever = "af697f3063d46fe9546f651c08c378f8"
    example = [
      Pigeon::IDENTITY_SIGIL,
      whatever,
      Pigeon::IDENTITY_FOOTER,
    ].join("")
    result = Pigeon::Helpers.decode_multihash(example)
    expect(result).to eq(Pigeon::Helpers.b32_decode(whatever))
  end
end
