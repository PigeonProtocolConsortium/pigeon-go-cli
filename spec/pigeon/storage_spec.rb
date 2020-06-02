require "spec_helper"

RSpec.describe Pigeon::Storage do
  LOGO_BLOB = File.read("./logo.png")
  IDS = %w[USER.ZMWM5PSXRN7RFRMSWW1E3V5DNGC4XGGJTHKCAGB48SNRG4XXE5NG
           USER.VF0Q4KXQNY6WCAXF17GAZGDPAX8XKM70SB8N7V0NSD1H370ZCJBG].freeze

  let(:db) do
    db = Pigeon::Database.new
    db.reset_database
    db
  end

  it "sets a config" do
    db._add_config("FOO", "BAR")
    value = db._get_config("FOO")
    expect(value).to eq("BAR")
    db._add_config("FOO", nil)
    value = db._get_config("FOO")
    expect(value).to eq(nil)
  end

  it "manages configs" do
    db._add_config("FOO", "BAR")
    value = db._get_config("FOO")
    expect(value).to eq("BAR")
  end

  it "manages blobs" do
    logo_hash = db.add_blob(LOGO_BLOB)
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

  it "finds all messages" do
    msgs = [
      db.add_message("strings", {
        "example_1.1" => "This is a string.",
        "example=_." => "A second string.",
      }),
      db.add_message("d", {
        "e" => db.add_blob(File.read("./logo.png")),
      }),
      db.add_message("g", {
        "me_myself_and_i" => db.who_am_i.multihash,
      }),
    ]
    me = db.who_am_i.multihash
    results = db.all_messages(me)
    expect(results.length).to eq(3)
    expect(msgs[0].multihash).to eq(results[0])
    expect(msgs[1].multihash).to eq(results[1])
    expect(msgs[2].multihash).to eq(results[2])
  end
end
