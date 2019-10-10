require "spec_helper"

RSpec.describe Pigeon::Storage do
  include FakeFS::SpecHelpers
  LOGO_BLOB = File.read("./logo.png")
  IDS = %w(@_TlC2z3FT4fimecC4eytrBhOwhLUZsVBZEZriBO9cWs=.ed25519
           @28FyT7evjcYrrwngr8G2V1HZ0ODK0VPsFctDEZwfZJc=.ed25519
           @ExA5Fmld-vMDjROfN30G5pmSp_261QILFP3qe64iDn8=.ed25519
           @galdahnB3L2DE2cTU0Me54IpIUKVEgKmBwvZVtWJccg=.ed25519
           @I6cN_IE9iPmH05xXnlI_WyLqnrAoKv1plUKWfiGSSK4=.ed25519
           @JnCKDs5tIzY9OF--GFT94Qj5jHtK7lTxqCt1tmPcwjM=.ed25519
           @q-_9BTnTThvW2ZGkmy8D3j-hW9ON2PNa3nwbCQgRw-g=.ed25519
           @VIim19-PzaavRICicQg4c4z08SoWTa1tr2e-kfhmm0Y=.ed25519)

  def test_fs
    FakeFS.with_fresh do
      yield(Pigeon::Storage.new)
    end
  end

  it "manages configs" do
    test_fs do |s|
      s.set_conf("FOO", "BAR")
      value = s.get_conf("FOO")
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
