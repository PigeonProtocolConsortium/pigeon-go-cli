require "json"
require "base64"
require "ed25519"
file = File.read("../scratchpad2.json")
json = JSON.parse(file)

message_plaintext = File.read("./scratchpad3.json").chomp
what_we_want = json[1]["signature"].gsub(".sig.ed25519", "")
seed = Base64.urlsafe_decode64(json[0]["private"].gsub!(".ed25519", ""))
signing_key = Ed25519::SigningKey.from_keypair(seed)
signature = signing_key.sign(message_plaintext)
signature_b64 = Base64.urlsafe_encode64(signature)

puts file
puts message_plaintext
puts "HAVE: " + signature_b64
puts "WANT: " + what_we_want
puts signature_b64 == what_we_want ? "HOORAY!!!" : "Did not work"
