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
    blobs = [db.create_message(db.put_blob("one"), { "a" => "b" }),
             db.create_message("a", { db.put_blob("two") => "b" }),
             db.create_message("a", { "b" => db.put_blob("three") })]
    normal = (1..10)
      .to_a
      .map do |n| { "foo" => ["bar", "123", SecureRandom.uuid].sample } end
      .map do |d| db.create_message(SecureRandom.uuid, d) end

    blobs + normal
  end

  it "creates a bundle" do
    expected_bundle = create_fake_messages.map(&:render).join("\n\n") + "\n"
    db.create_bundle
    actual_bundle = File.read(Pigeon::DEFAULT_BUNDLE_PATH)
    expect(expected_bundle).to eq(actual_bundle)
  end

  it "does not crash when ingesting old messages" do
    create_fake_messages
    db.create_bundle
    db.ingest_bundle
  end

  it "does not ingest messages from blocked peers" do
    db.reset_database
    antagonist = "@PPJQ3Q36W258VQ1NKYY2G7VW24J8NMAACHXCD83GCQ3K8F4C9X2G.ed25519"
    db.block_peer(antagonist)
    db.ingest_bundle("./spec/fixtures/x.bundle")
    expect(db.find_all_messages.count).to eq(0)
  end
end
