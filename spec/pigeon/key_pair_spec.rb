require "spec_helper"

RSpec.describe Pigeon::KeyPair do
  FAKE_SEED = "\x15\xB1\xA8\x1D\xE1\x1Cx\xF0" \
  "\xC6\xDCK\xDE\x9A\xB7>\x86o\x92\xEF\xB7\x17" \
  ")\xFF\x01E\b$b)\xC9\x82\b"
  TO_H = {
    private_key: "FbGoHeEcePDG3Evemrc-hm-S77cXKf8BRQgkYinJggg=",
    public_key: "@7n_g0ca9FFWvMkXy2TMwM7bdMn6tNiEHKzrFX-CzAmQ=.ed25519",
  }
  let(:kp) { Pigeon::KeyPair.new(FAKE_SEED) }

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

  it "converts to a Hash" do
    expect(kp.to_h).to eq(TO_H)
  end

  it "saves to disk" do
    TO_H.to_a.map do |pair|
      expect(Pigeon::Storage.current).to receive(:set_conf).with(*pair)
    end
    kp.save!
  end
end
