require "spec_helper"

RSpec.describe Pigeon::Message do
  before(:each) do
    p = Pigeon::DEFAULT_BUNDLE_PATH
    File.delete(p) if File.file?(p)
  end

  let(:db) { Pigeon::Database.new }

  def create_fake_messages
    (1..10)
      .to_a
      .map do |n| { "foo" => ["bar", "123", SecureRandom.uuid].sample } end
      .map do |d| db.create_message(SecureRandom.uuid, d) end
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
end
