RSpec.describe Pigeon::Helpers do
  it "handles Crockford Base 32 values" do
    10.times do
      raw_bytes = SecureRandom.random_bytes(32)
      encoded_bytes = Pigeon::Helpers.b32_encode(raw_bytes)
      decoded_bytes = Pigeon::Helpers.b32_decode(encoded_bytes)

      expect(raw_bytes).to eq(decoded_bytes)
    end
  end
end
