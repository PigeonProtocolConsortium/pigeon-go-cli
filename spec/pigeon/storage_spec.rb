require "spec_helper"

RSpec.describe Pigeon::Storage do
  LOGO_BLOB = File.read("./logo.png")
  IDS = %w(@_TlC2z3FT4fimecC4eytrBhOwhLUZsVBZEZriBO9cWs=.ed25519
           @28FyT7evjcYrrwngr8G2V1HZ0ODK0VPsFctDEZwfZJc=.ed25519)

  before(:each) do
    Pigeon::Storage.reset
    Pigeon::LocalIdentity.reset
  end

  let(:s) do
    Pigeon::Storage.current
  end

  it "deletes a config" do
    s.set_config("FOO", "BAR")
    value = s.get_config("FOO")
    expect(value).to eq("BAR")
    s.delete_config("FOO")
    value = s.get_config("FOO")
    expect(value).to eq(nil)
  end

  it "manages configs" do
    s.set_config("FOO", "BAR")
    value = s.get_config("FOO")
    expect(value).to eq("BAR")
  end

  it "manages blobs" do
    logo_hash = s.set_blob(LOGO_BLOB)
    expect(s.get_blob(logo_hash)).to eq(LOGO_BLOB)
  end

  it "manages peers" do
    s.add_peer(IDS[0])
    s.add_peer(IDS[1])
    expect(s.all_peers).to include(IDS[0])
    expect(s.all_peers).to include(IDS[1])

    s.remove_peer(IDS[0])
    expect(s.all_peers).not_to include(IDS[0])
    expect(s.all_blocks).not_to include(IDS[0])

    s.block_peer(IDS[1])
    expect(s.all_peers).not_to include(IDS[1])
    expect(s.all_blocks).to include(IDS[1])
    expect(s.all_blocks.count).to eq(1)
  end

  it "finds all authored by a particular feed" do
    ingested_messages = Pigeon::Bundle.ingest("./spec/fixtures/normal.bundle")
    author = ingested_messages.first.author.public_key
    actual_messages = Pigeon::Storage.current.find_all(author)
    search_results = Pigeon::Storage.current.find_all(author)
  end

  it "finds all messages" do
    msgs = [
      Pigeon::Helpers.create_message("strings", {
        "example_1.1" => "This is a string.",
        "example=_." => "A second string.",
      }),
      Pigeon::Helpers.create_message("d", {
        "e" => Pigeon::Storage.current.set_blob(File.read("./logo.png")),
      }),
      Pigeon::Helpers.create_message("g", {
        "me_myself_and_i" => Pigeon::LocalIdentity.current.public_key,
      }),
    ]
    me = Pigeon::LocalIdentity.current.public_key
    results = Pigeon::Storage.current.find_all(me)
    expect(results.length).to eq(3)
    expect(msgs[0].multihash).to eq(results[0])
    expect(msgs[1].multihash).to eq(results[1])
    expect(msgs[2].multihash).to eq(results[2])
  end
end
