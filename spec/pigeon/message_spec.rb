require "spec_helper"

RSpec.describe Pigeon::Message do
  before(:each) do
    Pigeon::Storage.reset
    Pigeon::LocalIdentity.reset
  end

  def create_draft(params)
    draft = Pigeon::Draft.create(kind: "unit_test")
    params.each { |(k, v)| draft[k] = v }
    draft
  end

  def create_message(params)
    draft = create_draft(params)
    Pigeon::Message.publish(draft)
  end

  let(:draft) do
    hash = Pigeon::Storage.current.set_blob(File.read("./logo.png"))
    create_draft({ "a" => "bar",
                   "b" => hash })
  end

  let (:template) do
    Pigeon::MessageSerializer.new(create_message({ "a" => "b" }))
  end

  it "discards a draft after signing" do
    expect(draft.internal_id).to eq(Pigeon::Draft.current.internal_id)
    Pigeon::Message.publish(draft)
    expect { Pigeon::Draft.current }.to raise_error("NO DRAFT FOUND")
  end

  it "creates a single message" do
    message = Pigeon::Message.publish(draft)
    expect(message.author).to eq(Pigeon::LocalIdentity.current)
    expect(message.body).to eq(draft.body)
    expect(message.depth).to eq(0)
    expect(message.kind).to eq("unit_test")
    expect(message.prev).to eq(Pigeon::EMPTY_MESSAGE)
    expect(message.signature.include?(Pigeon::SIG_FOOTER)).to eq(true)
    expect(message.signature.length).to be > 99
    actual = message.render
    expected = [
      "author __AUTHOR__",
      "kind unit_test",
      "prev NONE",
      "depth 0",
      "",
      "a:\"bar\"",
      "b:&NjQ2MmE1ZjUxNzRiNTM3MDJmYzI1YWZlNjdhOGY5YTI5ZjU3MjYxMGE2NWJhZmVmZmY2Mjc1MzE1NTJmMDk2Zg==.sha256",
      "",
      "signature __SIGNATURE__",
    ].join("\n")
      .gsub("__AUTHOR__", message.author.public_key)
      .gsub("__SIGNATURE__", message.signature)
    expect(actual).to eq(expected)
  end

  it "creates a chain of messages" do
    all = []
    0.upto(4) do |expected_depth|
      draft1 = Pigeon::Draft.create(kind: "unit_test")
      draft1["description"] = "Message number #{expected_depth}"
      message = Pigeon::Message.publish(draft1)
      all.push(message)
      expect(message.depth).to eq(expected_depth)
      if expected_depth == 0
        expect(message.prev).to eq(Pigeon::EMPTY_MESSAGE)
      else
        expect(message.prev).to eq(all[expected_depth - 1].multihash)
      end
    end
  end

  it "verifies accuracy of hash chain" do
    m1 = create_message({ "a" => "b" })
    m2 = create_message({ "c" => "d" })
    # ./dist/pigeon.rb:66:in `verify_string'
    # ./dist/pigeon/message.rb:70:in `verify_signature'
    # ./dist/pigeon/message.rb:47:in `verify!'
    # ./dist/pigeon/message.rb:82:in `initialize'

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

  # Init LocalIdentity
  # Get secret
  # Create signing key

  it "verifies accuracy of signatures" do
    # === Initial setup
    Pigeon::LocalIdentity.current
    secret = Pigeon::Storage.current.get_config(Pigeon::SEED_CONFIG_KEY)
    message = template.message
    plaintext = template.render_without_signature

    # Make fake pairs of data for cross-checking
    key1 = Pigeon::LocalIdentity.current.instance_variable_get(:@signing_key)
    key2 = Ed25519::SigningKey.new(secret)

    sig1 = key1.sign(plaintext)
    sig2 = key2.sign(plaintext)

    expect(key1.seed).to eq(key2.seed)
    expect(sig1).to eq(sig2)
    combinations = [[key1, sig1], [key1, sig2], [key2, sig1], [key2, sig2]]
    combinations.map { |(key, sig)| key.verify_key.verify(sig, plaintext) }

    sig1_b64 = Base64.urlsafe_encode64(sig1) + Pigeon::SIG_FOOTER
    sig2_b64 = Base64.urlsafe_encode64(sig2) + Pigeon::SIG_FOOTER
    expect(message.signature).to eq(sig1_b64)
    expect(message.signature).to eq(sig2_b64)
  end
end
