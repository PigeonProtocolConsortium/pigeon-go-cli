require "spec_helper"

RSpec.describe Pigeon::Storage do
  LOGO_BLOB = File.read("./logo.png")
  IDS = %w(@_TlC2z3FT4fimecC4eytrBhOwhLUZsVBZEZriBO9cWs=.ed25519
           @28FyT7evjcYrrwngr8G2V1HZ0ODK0VPsFctDEZwfZJc=.ed25519)
  let(:s) { Pigeon::Storage.current }

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
end
