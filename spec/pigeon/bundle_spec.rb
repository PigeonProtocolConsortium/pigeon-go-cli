require "spec_helper"

RSpec.describe Pigeon::Message do
  before(:each) do
    Pigeon::Storage.reset
    Pigeon::KeyPair.reset
  end

  def create_message(params)
    draft = Pigeon::Draft.create(kind: SecureRandom.uuid)
    params.map { |(k, v)| draft[k] = v }
    Pigeon::Message.publish(draft)
  end

  it "creates a bundle" do
    expected_bundle = (1..10)
      .to_a
      .map do |n| { "foo" => ["bar", 123, SecureRandom.uuid].sample } end
      .map do |d| create_message(d) end
      .map(&:render)
      .join("\n\n") + "\n"
    Pigeon::Bundle.create
    actual_bundle = File.read(Pigeon::DEFAULT_BUNDLE_PATH)
    expect(expected_bundle).to eq(actual_bundle)
  end
end
