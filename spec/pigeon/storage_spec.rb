require "spec_helper"

RSpec.describe Pigeon::Storage do
  LOGO_BLOB = File.read("./logo.png")
  IDS = %w(@ZMWM5PSXRN7RFRMSWW1E3V5DNGC4XGGJTHKCAGB48SNRG4XXE5NG.ed25519
           @VF0Q4KXQNY6WCAXF17GAZGDPAX8XKM70SB8N7V0NSD1H370ZCJBG.ed25519)

  let(:db) do
    db = Pigeon::Database.new
    db.reset
    db
  end

  it "sets a config" do
    db.set_config("FOO", "BAR")
    value = db.get_config("FOO")
    expect(value).to eq("BAR")
    db.set_config("FOO", nil)
    value = db.get_config("FOO")
    expect(value).to eq(nil)
  end

  it "manages configs" do
    db.set_config("FOO", "BAR")
    value = db.get_config("FOO")
    expect(value).to eq("BAR")
  end

  it "manages blobs" do
    logo_hash = db.put_blob(LOGO_BLOB)
    expect(db.get_blob(logo_hash)).to eq(LOGO_BLOB)
  end

  it "manages peers" do
    db.add_peer(IDS[0])
    db.add_peer(IDS[1])
    expect(db.all_peers).to include(IDS[0])
    expect(db.all_peers).to include(IDS[1])

    db.remove_peer(IDS[0])
    expect(db.all_peers).not_to include(IDS[0])
    expect(db.all_blocks).not_to include(IDS[0])

    db.block_peer(IDS[1])
    expect(db.all_peers).not_to include(IDS[1])
    expect(db.all_blocks).to include(IDS[1])
    expect(db.all_blocks.count).to eq(1)
  end

  it "finds all authored by a particular feed" do
    ingested_messages = db.ingest_bundle("./spec/fixtures/normal.bundle")
    author = ingested_messages.first.author.multihash
    actual_messages = db.find_all(author)
    search_results = db.find_all(author)
  end

  it "finds all messages" do
    msgs = [
      db.create_message("strings", {
        "example_1.1" => "This is a string.",
        "example=_." => "A second string.",
      }),
      db.create_message("d", {
        "e" => db.put_blob(File.read("./logo.png")),
      }),
      db.create_message("g", {
        "me_myself_and_i" => db.local_identity.multihash,
      }),
    ]
    me = db.local_identity.multihash
    results = db.find_all(me)
    expect(results.length).to eq(3)
    expect(msgs[0].multihash).to eq(results[0])
    expect(msgs[1].multihash).to eq(results[1])
    expect(msgs[2].multihash).to eq(results[2])
  end
end
