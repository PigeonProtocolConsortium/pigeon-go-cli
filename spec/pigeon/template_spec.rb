require "spec_helper"

RSpec.describe Pigeon::Template do
  MessageShim = Struct.new(:author, :body, :kind, :depth, :prev, :signature)
  EXPECTED_DRAFT =
    "author FAKE_AUTHOR\ndepth DRAFT\nkind FAKE_KIND\nprev DRAFT\n\n\nsignature DRAFT\n\n"
  it "renders a DRAFT" do
    args = ["FAKE_AUTHOR",
            nil,
            "FAKE_KIND",
            nil,
            nil,
            nil]
    message = MessageShim.new(*args)
    result = Pigeon::Template.new(message).render
    expect(result).to eq(EXPECTED_DRAFT)
  end
end
