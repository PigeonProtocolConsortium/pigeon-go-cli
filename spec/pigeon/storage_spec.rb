require "spec_helper"

RSpec.describe Pigeon::Storage do
  include FakeFS::SpecHelpers
  LOGO_BLOB = File.read("./logo.png")
  IDS = %w(@_TlC2z3FT4fimecC4eytrBhOwhLUZsVBZEZriBO9cWs=.ed25519
           @28FyT7evjcYrrwngr8G2V1HZ0ODK0VPsFctDEZwfZJc=.ed25519)

  def test_fs
    FakeFS.with_fresh do
      yield(Pigeon::Storage.new)
    end
  end

  it "manages configs" do
    test_fs do |s|
      s.set_config("FOO", "BAR")
      value = s.get_config("FOO")
      expect(value).to eq("BAR")
    end
  end

  it "manages blobs" do
    test_fs do |s|
      logo_hash = s.set_blob(LOGO_BLOB)
      expect(s.get_blob(logo_hash)).to eq(LOGO_BLOB)
    end
  end

  it "manages peers" do
    test_fs do |s|
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
end
