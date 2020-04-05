require_relative "./dist/pigeon"
require "pry"

# http://www.crockford.com/wrmg/base32.html
class Base32
  ENCODER = [
    "0",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "A",
    "B",
    "C",
    "D",
    "E",
    "F",
    "G",
    "H",
    "J",
    "K",
    "M",
    "N",
    "P",
    "Q",
    "R",
    "S",
    "T",
    "V",
    "W",
    "X",
    "Y",
    "Z",
  ].freeze

  DECODER = {
    "0" => 0,
    "O" => 0,

    "1" => 1,
    "I" => 1,
    "L" => 1,

    "2" => 2,
    "3" => 3,
    "4" => 4,
    "5" => 5,
    "6" => 6,
    "7" => 7,
    "8" => 8,
    "9" => 9,
    "A" => 10,
    "B" => 11,
    "C" => 12,
    "D" => 13,
    "E" => 14,
    "F" => 15,
    "G" => 16,
    "H" => 17,
    "J" => 18,
    "K" => 19,
    "M" => 20,
    "N" => 21,
    "P" => 22,
    "Q" => 23,
    "R" => 24,
    "S" => 25,
    "T" => 26,
    "V" => 27,
    "W" => 28,
    "X" => 29,
    "Y" => 30,
    "Z" => 31,
  }.freeze

  def self.encode(string)
    string
      .each_byte
      .to_a
      .map { |x| x.to_s(2).rjust(8, "0") }
      .join
      .scan(/.{1,5}/)
      .map { |x| x.rjust(5, "0") }
      .map { |bits| ENCODER.fetch(bits.to_i(2)) }
      .join
  end

  def self.decode(string)
    string
      .split("")
      .map { |x| DECODER.fetch(x.upcase) }
      .map { |x| x.to_s(2).rjust(5, "0") }
      .join("")
      .scan(/.{1,8}/)
      .map do |x|
      # This is where problems start.
      # binding.pry if x.length != 5
      x.to_i(2).chr
    end
      .join("")
  end
end

[
  "How razorback jumping frogs can level six piqued gymnasts.",
  "Sixty zippers were quickly picked from the woven jute bag.",
  "Crazy Fredrick bought many very exquisite opal jewels.",
  "Jump by vow of quick, lazy strength in Oxford.",
  "The quick brown fox jumps over a lazy dog.",
  "How quickly daft jumping zebras vex.",
  "Sphinx of black quartz: judge my vow.",
  "Quick zephyrs blow, vexing daft Jim.",
  "Waltz, nymph, for quick jigs vex bud.",
].select do |x|
  puts "==="
  y = Base32.encode(x)
  z = Base32.decode(y)
  puts y
  puts z
  puts x
end
