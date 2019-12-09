require "spec_helper"

RSpec.describe Pigeon::Message do
  let(:message) do
    message = Pigeon::Message.create(kind: "unit_test")
    hash = Pigeon::Storage.current.set_blob(File.read("./logo.png"))
    message.append("a", "bar")
    message.append("b", hash)
    message.sign
    message
  end

  it "signs a message" do
    test_me = message
    raise "need better assertions!"
  end

  MSG = [
    "author ___",
    "kind unit_test",
    "prev NONE",
    "depth 0\n",
    "a:\"bar\"",
    "b:&6462a5f5174b53702fc25afe67a8f9a29f572610a65bafefff627531552f096f.sha256\n",
    "signature ",
  ].join("\n")

  it "renders a first message" do
    pk = Pigeon::KeyPair.current.public_key
    actual = message.render
    expected = MSG.gsub("___", pk)
    expect(actual).to start_with(expected)
    puts "TODO: Write a test for deterministic verification of signatures"
    puts "current tests only test top parts of message, not signature."
  end

  it "creates a new message" do
    message = Pigeon::Message.create(kind: "unit_test")
    hash = Pigeon::Storage.current.set_blob(File.read("./logo.png"))
    expectations = {
      author: Pigeon::KeyPair.current.public_key,
      kind: "unit_test",
      body: {
        "a" => "bar".to_json,
        "b" => hash,
      },
      depth: 0,
      prev: Pigeon::Message::EMPTY_MESSAGE,
    }
    message.append("a", "bar")
    message.append("b", hash)
    expect(message.author).to eq(Pigeon::KeyPair.current.public_key)
    expect(message.kind).to eq("unit_test")
    expect(message.body).to eq(expectations.fetch(:body))
    expect(message.depth).to eq(0)
    expect(message.prev).to eq(Pigeon::Message::EMPTY_MESSAGE)
    expectations.map do |k, v|
      expect(Pigeon::Message.current.send(k)).to eq(v)
    end
  end
end
