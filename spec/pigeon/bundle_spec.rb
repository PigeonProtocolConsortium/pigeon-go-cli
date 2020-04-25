require "spec_helper"

RSpec.describe Pigeon::Message do
  before(:each) do
    p = Pigeon::DEFAULT_BUNDLE_PATH
    File.delete(p) if File.file?(p)
  end

  let(:db) do
    db = Pigeon::Database.new
    db.reset_database
    db
  end

  def create_fake_messages
    blobs = [db.add_message(db.add_blob("one"), { "a" => "b" }),
             db.add_message("a", { db.add_blob("two") => "b" }),
             db.add_message("a", { "b" => db.add_blob("three") })]
    normal = (1..10)
      .to_a
      .map { |_n| { "foo" => ["bar", "123", SecureRandom.uuid].sample } }
      .map { |d| db.add_message(SecureRandom.uuid, d) }

    blobs + normal
  end

  it "creates a bundle" do
    expected_bundle = create_fake_messages.map(&:render).join("\n\n") + "\n"
    db.export_bundle
    actual_bundle = File.read(File.join(Pigeon::DEFAULT_BUNDLE_PATH, "gossip.pgn"))
    expect(expected_bundle).to eq(actual_bundle)
  end

  it "does not crash when ingesting old messages" do
    create_fake_messages
    db.export_bundle
    db.import_bundle
  end

  it "does not ingest messages from blocked peers" do
    db.reset_database
    antagonist = "@PPJQ3Q36W258VQ1NKYY2G7VW24J8NMAACHXCD83GCQ3K8F4C9X2G.ed25519"
    db.block_peer(antagonist)
    db.import_bundle("./spec/fixtures/x")
    expect(db.all_messages.count).to eq(0)
  end

  it "ingests a bundle's blobs" do
    db.reset_database
    db.add_message(db.add_blob(File.read("a.gif")), {
      db.add_blob(File.read("b.gif")) => db.add_blob(File.read("c.gif")),
    })
    db.export_bundle("./spec/fixtures/has_blobs")
    warn("The directory structure is not correct.")
    exit(1)
    db.import_bundle("./spec/fixtures/has_blobs")
    expect(db.all_messages.count).to eq(0)
  end
end
