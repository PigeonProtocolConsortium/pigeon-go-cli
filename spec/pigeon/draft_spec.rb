require "spec_helper"

RSpec.describe Pigeon::Draft do
  let(:db) do
    db = Pigeon::Database.new
    db.reset_database
    db
  end

  let(:message) do
    db.reset_draft
    db.new_draft(kind: "unit_test")
    logo = File.read("./logo.png")
    db.update_draft("a", "bar")
    db.update_draft("b", db.add_blob(logo))
    db.get_draft
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
    pk = db.who_am_i.multihash
    actual = message.render_as_draft
    expected = MSG.gsub("___", pk)
    expect(actual).to start_with(expected)
  end

  it "creates a new message" do
    db.reset_draft
    db.new_draft(kind: "unit_test")
    hash = db.add_blob(File.read("./logo.png"))
    expectations = {
      kind: "unit_test",
      body: {
        "a" => "bar".to_json,
        "b" => hash,
      },
    }
    db.update_draft("a", "bar")
    db.update_draft("b", hash)
    expect(message["a"]).to eq(expectations.dig(:body, "a"))
    expect(message["b"]).to eq(expectations.dig(:body, "b"))
    expect(message.kind).to eq("unit_test")
    expect(message.body).to eq(expectations.fetch(:body))
    expectations.map do |k, v|
      left = db.get_draft.send(k)
      expect(left).to eq(v)
    end
  end
end
