RSpec.describe Pigeon::Helpers do
  it "creates lipmalinks" do
    [
      [-1, 0],
      [0, 0],
      [1, 0],
      [2, 1],
      [3, 2],
      [4, 1],
      [5, 4],
      [6, 5],
      [7, 6],
      [8, 4],
      [13, 4],
    ].map do |(input, expected)|
      actual = Pigeon::Helpers.lipmaa(input)
      expect(actual).to eq(expected)
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
