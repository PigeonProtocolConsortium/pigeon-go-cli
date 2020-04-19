require "spec_helper"

RSpec.describe Pigeon::Draft do
  let(:db) do
    db = Pigeon::Database.new
    db.reset_database
    db
  end

  let(:message) do
    message = db.create_draft(kind: "unit_test")
    hash = db.put_blob(File.read("./logo.png"))
    message.put(db, "a", "bar")
    message.put(db, "b", hash)
    message
  end

  MSG = [
    "author DRAFT",
    "kind unit_test",
    "prev DRAFT",
    "depth DRAFT",
    "lipmaa DRAFT",
    "\na:\"bar\"",
    "b:&CHHABX8Q9D9Q0BY2BBZ6FA7SMAFNE9GGMSDTZVZZC9TK2N9F15QG.sha256",
    "\n",
  ].join("\n")

  it "renders a message" do
    pk = db.local_identity.multihash
    actual = message.render_as_draft
    expected = MSG.gsub("___", pk)
    expect(actual).to start_with(expected)
  end

  it "creates a new message" do
    message = db.create_draft(kind: "unit_test")
    hash = db.put_blob(File.read("./logo.png"))
    expectations = {
      kind: "unit_test",
      body: {
        "a" => "bar".to_json,
        "b" => hash,
      },
    }
    message.put(db, "a", "bar")
    message.put(db, "b", hash)
    expect(message["a"]).to eq(expectations.dig(:body, "a"))
    expect(message["b"]).to eq(expectations.dig(:body, "b"))
    expect(message.kind).to eq("unit_test")
    expect(message.body).to eq(expectations.fetch(:body))
    expectations.map do |k, v|
      left = db.current_draft.send(k)
      expect(left).to eq(v)
    end
  end
end
