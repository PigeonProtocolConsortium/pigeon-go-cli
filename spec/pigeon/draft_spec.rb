require "spec_helper"

RSpec.describe Pigeon::Draft do
  let(:message) do
    message = Pigeon::Draft.create(kind: "unit_test")
    hash = Pigeon::Storage.current.set_blob(File.read("./logo.png"))
    message["a"] = "bar"
    message["b"] = hash
    message
  end

  before(:each) do
    Pigeon::Storage.reset
    Pigeon::KeyPair.reset
  end

  MSG = [
    "author DRAFT",
    "kind unit_test",
    "prev DRAFT",
    "depth DRAFT",
    "\na:\"bar\"",
    "b:&6462a5f5174b53702fc25afe67a8f9a29f572610a65bafefff627531552f096f.sha256",
    "\n"
  ].join("\n")

  it "renders a message" do
    pk = Pigeon::KeyPair.current.public_key
    actual = message.render
    expected = MSG.gsub("___", pk)

    expect(actual).to start_with(expected)
  end

  it "creates a new message" do
    message = Pigeon::Draft.create(kind: "unit_test")
    hash = Pigeon::Storage.current.set_blob(File.read("./logo.png"))
    expectations = {
      kind: "unit_test",
      body: {
        "a" => "bar".to_json,
        "b" => hash,
      }
    }
    message["a"] = "bar"
    message["b"] = hash
    expect(message["a"]).to eq(expectations.dig(:body, "a"))
    expect(message["b"]).to eq(expectations.dig(:body, "b"))
    expect(message.kind).to eq("unit_test")
    expect(message.body).to eq(expectations.fetch(:body))
    expectations.map do |k, v|
      expect(Pigeon::Draft.current.send(k)).to eq(v)
    end
  end
end
