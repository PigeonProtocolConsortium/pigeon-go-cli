require "spec_helper"

RSpec.describe Pigeon::MessageSerializer do
  SHIM_ATTRS = [:author, :body, :kind, :depth, :prev, :signature, :saved?]
  MessageShim = Struct.new(*SHIM_ATTRS)
  TOP_HALF = ["author FAKE_AUTHOR",
              "\nkind FAKE_KIND",
              "\nprev NONE",
              "\ndepth 23",
              "\n\nfoo:\"bar\"\n\n"].join("")
  BOTTOM_HALF = "signature XYZ.sig.sha256"
  EXPECTED_DRAFT = TOP_HALF + BOTTOM_HALF

  class FakeKeypair
    def self.public_key
      "FAKE_AUTHOR"
    end
  end

  it "renders a draft" do
    args = [FakeKeypair,
            { foo: "bar".inspect },
            "FAKE_KIND",
            23,
            nil,
            "XYZ.sig.sha256",
            false]
    message = MessageShim.new(*args)
    template = Pigeon::MessageSerializer.new(message)
    expect(template.render).to eq(EXPECTED_DRAFT)
    expect(template.render_without_signature).to eq(TOP_HALF)
  end
end
