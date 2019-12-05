require "spec_helper"

RSpec.describe Pigeon::Message do
  it "signs a message" do
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
    message.sign
    raise "need better assertions!"
  end

  it "renders a message"
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
