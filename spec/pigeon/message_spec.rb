require "spec_helper"
require "timeout"

RSpec.describe Pigeon::Message do
  def another_draft(params)
    db.delete_current_draft
    db.new_draft(kind: "unit_test", body: params)
    db.get_draft
  end

  def add_message(params)
    draft = another_draft(params)
    db.publish_draft(draft)
  end

  let(:db) do
    db = Pigeon::Database.new
    db.reset_database
    db
  end

  let(:draft) do
    hash = db.add_blob(File.read("./logo.png"))
    another_draft({ "a" => "bar", "b" => hash })
  end

  let(:templated_message) { add_message({ "a" => "b" }) }

  let (:template) do
    Pigeon::MessageSerializer.new(templated_message)
  end

  it "discards a draft after signing" do
    db.publish_draft(draft)
    err = "THERE IS NO DRAFT. CREATE ONE FIRST. Call db.new_draft(kind, body)"
    expect { db.get_draft }.to raise_error(err)
  end

  it "creates a single message" do
    message = db.publish_draft(draft)
    expect(message.author.multihash).to eq(db.who_am_i.multihash)
    expect(message.body).to eq(draft.body)
    expect(message.depth).to eq(0)
    expect(message.kind).to eq("unit_test")
    expect(message.prev).to eq(Pigeon::NOTHING)
    expect(message.signature.include?(Pigeon::SIG_FOOTER)).to eq(true)
    expect(message.signature.length).to be > 99
    actual = message.render
    expected = [
      "author __AUTHOR__",
      "kind unit_test",
      "prev NONE",
      "depth 0",
      "lipmaa NONE",
      "",
      "a:\"bar\"",
      "b:&CHHABX8Q9D9Q0BY2BBZ6FA7SMAFNE9GGMSDTZVZZC9TK2N9F15QG.sha256",
      "",
      "signature __SIGNATURE__",
    ].join("\n")
      .gsub("__AUTHOR__", message.author.multihash)
      .gsub("__SIGNATURE__", message.signature)
    expect(actual).to eq(expected)
  end

  it "creates a chain of messages" do
    all = []
    0.upto(4) do |expected_depth|
      db.delete_current_draft
      db.new_draft(kind: "unit_test")
      db.update_draft("description", "Message number #{expected_depth}")
      message = db.publish_draft
      all.push(message)
      expect(message.depth).to eq(expected_depth)
      if expected_depth == 0
        expect(message.prev).to eq(Pigeon::NOTHING)
      else
        expect(message.prev).to eq(all[expected_depth - 1].multihash)
      end
    end
  end

  it "verifies accuracy of hash chain" do
    m1 = add_message({ "a" => "b" })
    m2 = add_message({ "c" => "d" })
    m3 = add_message({ "e" => "f" })
    m4 = add_message({ "g" => "h" })

    expect(m1.prev).to eq(Pigeon::NOTHING)
    expect(m2.prev).to be
    expect(m2.prev).to eq(m1.multihash)
    expect(m3.prev).to eq(m2.multihash)
    expect(m3.prev).to be
    expect(m4.prev).to eq(m3.multihash)
    expect(m4.prev).to be
  end

  it "does not allow message with more than 64 keys" do
    error = "Messages cannot have more than 64 keys. Got 65."
    body = {}
    65.times do
      body[SecureRandom.hex(6)] = SecureRandom.hex(6)
    end
    expect do
      add_message(body)
    end.to raise_error(Pigeon::Helpers::MessageSizeError, error)
  end

  it "verifies accuracy of signatures" do
    # === Initial setup
    secret = db._get_config(Pigeon::SEED_CONFIG_KEY)
    expect(secret).to be_kind_of(String)
    message = templated_message
    plaintext = template.render_without_signature

    # Make fake pairs of data for cross-checking
    key1 = db.who_am_i.instance_variable_get(:@signing_key)
    key2 = Ed25519::SigningKey.new(secret)

    sig1 = key1.sign(plaintext)
    sig2 = key2.sign(plaintext)

    expect(key1.seed).to eq(key2.seed)
    expect(sig1).to eq(sig2)
    combinations = [[key1, sig1], [key1, sig2], [key2, sig1], [key2, sig2]]
    combinations.map { |(key, sig)| key.verify_key.verify(sig, plaintext) }

    sig1_b64 = Pigeon::Helpers.b32_encode(sig1) + Pigeon::SIG_FOOTER
    sig2_b64 = Pigeon::Helpers.b32_encode(sig2) + Pigeon::SIG_FOOTER
    expect(message.signature).to eq(sig1_b64)
    expect(message.signature).to eq(sig2_b64)
  end

  it "crashes on forged fields" do
    tokens = [
      [:AUTHOR, "@DYdgK1KUInVtG3lS45hA1HZ-jTuvfLKsxDpXPFCve04=.ed25519"],
      [:KIND, "invalid"],
      [:PREV, "NONE"],
      [:DEPTH, 10],
      [:LIPMAA, "%4PE7S4XCCAYPQ42S98K730CEW6ME5HRWJKHHEGYVYPFHSJWXEY1G.sha256"],
      [:HEADER_END],
      [:BODY_ENTRY, "duplicate", "This key is a duplicate."],
      [:SIGNATURE, "DN7yPTE-m433ND3jBL4oM23XGxBKafjq0Dp9ArBQa_TIGU7DmCxTumieuPBN-NKxlx_0N7-c5zjLb5XXVHYPCQ==.sig.ed25519"],
      [:MESSAGE_END],
    ]
    e = Pigeon::Helpers::VerificationError
    m = "Expected field `depth` to equal 0, got: 10"
    expect do
      msg = Pigeon::Parser.parse(db, tokens)[0]
    end.to raise_error(e, m)
  end

  # Every ASCII character that is not a letter:
  WHITESPACE = (0..32).to_a.map(&:chr).push(127.chr)

  it "does not allow whitespace in `kind` attributes" do
    WHITESPACE.map do |n|
      kind = SecureRandom.alphanumeric(8)
      kind[rand(0...8)] = n
      db.delete_current_draft
      db.new_draft(kind: kind)
      boom = -> { db.publish_draft.render }
      expect(boom).to raise_error(Pigeon::Lexer::LexError)
    end
  end

  # This was originally a bug nooted during development
  # That caused a runaway loop in the tokenizer.
  it "handles this key: '\\nVUx0hC3'" do
    db.delete_current_draft
    db.new_draft(kind: "unit_test")
    db.update_draft("\nVUx0hC3", "n")
    db.update_draft("n", "\nVUx0hC3")
    Timeout::timeout(0.5) do
      boom = -> { Pigeon::Lexer.tokenize(db.publish_draft.render) }
      expect(boom).to raise_error("RUNAWAY LOOP DETECTED")
    end
  end

  it "does not allow whitespace in key names" do
    WHITESPACE.map do |n|
      db.delete_current_draft
      db.new_draft(kind: "unit_test")
      key = SecureRandom.alphanumeric(8)
      key[rand(0...8)] = n
      db.update_draft(key, "should crash")
      boom = -> { Pigeon::Lexer.tokenize(db.publish_draft.render) }
      expect(boom).to raise_error(Pigeon::Lexer::LexError)
    end
  end
end
