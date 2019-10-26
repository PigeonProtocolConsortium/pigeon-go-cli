require "spec_helper"

RSpec.describe Pigeon::KeyPair do
  FAKE_SEED = "\x15\xB1\xA8\x1D\xE1\x1Cx\xF0" \
  "\xC6\xDCK\xDE\x9A\xB7>\x86o\x92\xEF\xB7\x17" \
  ")\xFF\x01E\b$b)\xC9\x82\b"
  let(:kp) { Pigeon::KeyPair.new(FAKE_SEED) }

  HELLO_SIGNATURE = [
    "erGeJdWiWzDJpKJdkLSc5uBc90j5t90aPcbCehLp6Xg",
    "tF8f_2AYWXl6ou4oquvEOQVMgrTGuN-q6F9tTW-V5Bw",
    "==.sig.ed25519",
  ].join("")
  it "signs arbitrary data" do
    expect(kp.sign("hello")).to eq(HELLO_SIGNATURE)
  end

  it "generates a pair from a seed" do
    x = "@7n_g0ca9FFWvMkXy2TMwM7bdMn6tNiEHKzrFX-CzAmQ=.ed25519"
    expect(kp.public_key).to eq(x)
    y = "FbGoHeEcePDG3Evemrc-hm-S77cXKf8BRQgkYinJggg="
    expect(kp.private_key).to eq(y)
  end

  it "strips headers" do
    whatever = "af697f3063d46fe9546f651c08c378f8"
    example = [
      Pigeon::KeyPair::HEADER,
      whatever,
      Pigeon::KeyPair::FOOTER,
    ].join("")
    result = Pigeon::KeyPair.strip_headers(example)
    expect(result).to eq(whatever)
  end

  it "saves to disk" do
    argss = [
      Pigeon::KeyPair::SEED_CONFIG_KEY,
      FAKE_SEED,
    ]
    FakeFS.with_fresh do
      lol = receive(:set_config).with(*argss).and_call_original
      expect(Pigeon::Storage.current).to lol
      kp.save!
      new_kp = Pigeon::KeyPair.current
      expect(new_kp.public_key).to eq(kp.public_key)
      expect(new_kp.private_key).to eq(kp.private_key)
    end
  end
end
