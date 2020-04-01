require "spec_helper"

RSpec.describe Pigeon::Message do
  before(:each) do
    p = Pigeon::DEFAULT_BUNDLE_PATH
    File.delete(p) if File.file?(p)
    Pigeon::Storage.reset
    Pigeon::LocalIdentity.reset
  end

  def create_message(params)
    draft = Pigeon::Draft.create(kind: SecureRandom.uuid)
    params.map { |(k, v)| draft[k] = v }
    Pigeon::Message.publish(draft)
  end

  def create_fake_messages
    (1..10)
      .to_a
      .map do |n| { "foo" => ["bar", "123", SecureRandom.uuid].sample } end
      .map do |d| create_message(d) end
  end

  it "creates a bundle" do
    expected_bundle = create_fake_messages.map(&:render).join("\n\n") + "\n"
    Pigeon::Bundle.create
    actual_bundle = File.read(Pigeon::DEFAULT_BUNDLE_PATH)
    expect(expected_bundle).to eq(actual_bundle)
  end

  it "debugs a problem" do
    seed = "\xA3@\x12\xA6\x8Cl\x83\xF5)\x97\xED\xE67\x91\xAD\xFD\xCFf\xF4(\xEF\x81P\xBBD\xF7\x8C\xF7\x8D\xC0\xA9\f"
    ident = Pigeon::LocalIdentity.new(seed)
    Pigeon::LocalIdentity.instance_variable_set(:@current, ident)
    create_fake_messages
    Pigeon::Bundle.create
    Pigeon::Bundle.ingest
  end
end
