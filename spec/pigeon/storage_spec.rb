require "spec_helper"

RSpec.describe Pigeon::Storage do
  include FakeFS::SpecHelpers
  it "does something to the filesystem" do
    FakeFS.with_fresh do
      expect(2 + 2).to eq(4)
    end
  end
end
