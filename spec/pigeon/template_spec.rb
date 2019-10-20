require "spec_helper"

RSpec.describe Pigeon::Template do
  MessageShim = Struct.new(:author, :body, :kind, :depth, :prev, :signature)
  EXPECTED_DRAFT = [
    "\nauthor FAKE_AUTHOR",
    "\nkind FAKE_KIND",
    "\nprev DRAFT",
    "\ndepth DRAFT",
    "\n\n\nsignature DRAFT \n\n",
  ].join("")
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
