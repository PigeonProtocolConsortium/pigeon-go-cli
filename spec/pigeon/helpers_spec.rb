RSpec.describe Pigeon::Helpers do
  it "creates lipmalinks" do
    [
      [-1, nil],
      [0, nil],
      [1, nil],
      [2, nil],
      [3, nil],
      [4, 1],
      [5, nil],
      [6, nil],
      [7, nil],
      [8, 4],
      [13, 4],
    ].each do |(input, expected)|
      expect(Pigeon::Helpers.lipmaa(input)).to eq(expected)
    end
  end

  it "handles Crockford Base 32 values" do
    10.times do
      raw_bytes = SecureRandom.random_bytes(32)
      encoded_bytes = Pigeon::Helpers.b32_encode(raw_bytes)
      decoded_bytes = Pigeon::Helpers.b32_decode(encoded_bytes)

      expect(raw_bytes).to eq(decoded_bytes)
    end
  end
end
