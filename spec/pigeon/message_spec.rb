require "spec_helper"

RSpec.describe Pigeon::Message do
  before(:each) do
    Pigeon::Storage.reset
    Pigeon::KeyPair.reset
  end

  def create_draft(params)
    draft = Pigeon::Draft.create(kind: "unit_test")
    params.each { |(k, v)| draft[k] = v }
    draft
  end

  def create_message(params)
    draft = create_draft(params)
    Pigeon::Message.from_draft(draft)
  end

  let(:draft) do
    hash = Pigeon::Storage.current.set_blob(File.read("./logo.png"))
    create_draft({ "a" => "bar",
                   "b" => hash })
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
        expect(message.prev).to eq(all[n - 2].multihash)
      else
        expect(message.prev).to be nil
      end
    end
  end

  it "verifies accuracy of hash chain" do
    m1 = create_message({ "a" => "b" })
    m2 = create_message({ "c" => "d" })
    m3 = create_message({ "e" => "f" })
    m4 = create_message({ "g" => "h" })
    expect(m1.prev).to eq(nil)
    expect(m2.prev).to be
    expect(m2.prev).to eq(m1.multihash)
    expect(m3.prev).to eq(m2.multihash)
    expect(m3.prev).to be
    expect(m4.prev).to eq(m3.multihash)
    expect(m4.prev).to be
  end

  it "verifies accuracy of signatures" do
    m1 = create_message({ "a" => "b" })
    template = Pigeon::Serializer.new(m1)
    string = template.render_without_signature
    secret = Pigeon::Storage.current.get_config(Pigeon::SEED_CONFIG_KEY)
    expect(secret.length).to eq(32)
    signing_key = Ed25519::SigningKey.new(secret)
    raw_signature = signing_key.sign(string)
    b64_signature = Base64.urlsafe_encode64(raw_signature)
    signature = b64_signature + ".sig.ed25519"
    expect(m1.signature).to eq(signature)
  end
end
