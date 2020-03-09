require "spec_helper"

RSpec.describe Pigeon::Message do
  before(:each) do
    Pigeon::Storage.reset
    Pigeon::KeyPair.reset
  end

  let(:draft) do
    draft = Pigeon::Draft.create(kind: "unit_test")
    hash = Pigeon::Storage.current.set_blob(File.read("./logo.png"))
    draft["a"] = "bar"
    draft["b"] = hash
    draft
  end

  it "discards a draft after signing" do
    expect(draft.internal_id).to eq(Pigeon::Draft.current.internal_id)
    Pigeon::Message.from_draft(draft)
    expect(Pigeon::Draft.current).to be nil
  end

  it "creates a single message" do
    message = Pigeon::Message.from_draft(draft)
    expect(message.author).to eq(Pigeon::KeyPair.current)
    expect(message.body).to eq(draft.body)
    expect(message.depth).to eq(0)
    expect(message.kind).to eq("unit_test")
    expect(message.prev).to eq(nil)
    expect(message.signature.include?(".sig.ed25519")).to eq(true)
    expect(message.signature.length).to be > 99
    actual = message.render
    expected = [
      "author __AUTHOR__",
      "kind unit_test",
      "prev NONE",
      "depth 0",
      "",
      "a:\"bar\"",
      "b:&6462a5f5174b53702fc25afe67a8f9a29f572610a65bafefff627531552f096f.sha256",
      "",
      "signature __SIGNATURE__",
    ].join("\n")
      .gsub("__AUTHOR__", message.author.public_key)
      .gsub("__SIGNATURE__", message.signature)
    expect(actual).to eq(expected)
  end

  it "creates a chain of messages" do
    all = []
    1.upto(5) do |n|
      expected_depth = n - 1
      draft1 = Pigeon::Draft.create(kind: "unit_test")
      draft1["description"] = "Message number #{n}"
      message = Pigeon::Message.from_draft(draft1)
      all.push(message)
      expect(message.depth).to eq(expected_depth)
      if n > 1
        expect(message.prev).to eq(all[n - 2].signature)
      else
        expect(message.prev).to be nil
      end
    end
  end

  it "verifies accuracy of signature chain"
end
