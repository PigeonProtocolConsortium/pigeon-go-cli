require "spec_helper"

RSpec.describe Pigeon::KeyPair do
  FAKE_SEED = "\x15\xB1\xA8\x1D\xE1\x1Cx\xF0" \
  "\xC6\xDCK\xDE\x9A\xB7>\x86o\x92\xEF\xB7\x17" \
  ")\xFF\x01E\b$b)\xC9\x82\b"

  let(:kp) { Pigeon::KeyPair.new(FAKE_SEED) }

  it "generates a pair from a seed" do
    x = "@7n_g0ca9FFWvMkXy2TMwM7bdMn6tNiEHKzrFX-CzAmQ=.ed25519"
    expect(kp.public_key).to eq(x)
    y = "FbGoHeEcePDG3Evemrc-hm-S77cXKf8BRQgkYinJggg="
    expect(kp.private_key).to eq(y)
  end

  # TODO Add fakefs https://github.com/fakefs/fakefss
  it "saves keypairs to disk"
end
