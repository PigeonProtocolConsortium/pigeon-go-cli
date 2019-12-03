require "spec_helper"

RSpec.describe Pigeon::Message do
  it "creates a new message" do
    message = Pigeon::Message.create(kind: "unit_test")
    expect(message.author).to eq(Pigeon::KeyPair.current.public_key)
    expect(message.kind).to eq("unit_test")
    expect(message.body).to eq({})
    expect(message.depth).to eq(0)
    expect(message.prev).to eq(Pigeon::Message::EMPTY_MESSAGE)
    expect(Pigeon::Message.current).to eq(message)
    message.append("foo", "bar")
  end
end
