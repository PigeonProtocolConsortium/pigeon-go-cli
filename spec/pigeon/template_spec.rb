require "spec_helper"

RSpec.describe Pigeon::Template do
  SHIM_ATTRS = [:author, :body, :kind, :depth, :prev, :signature, :saved?]
  MessageShim = Struct.new(*SHIM_ATTRS)
  TOP_HALF = ["author FAKE_AUTHOR",
              "\nkind FAKE_KIND",
              "\nprev NONE",
              "\ndepth 23",
              "\n\nfoo:\"bar\"\n\n"].join("")
  BOTTOM_HALF = "signature XYZ.sig.sha256 \n"
  EXPECTED_DRAFT = TOP_HALF + BOTTOM_HALF

  it "renders a draft" do
    args = ["FAKE_AUTHOR",
            { foo: "bar".inspect },
            "FAKE_KIND",
            23,
            nil,
            "XYZ.sig.sha256",
            false]
    message = MessageShim.new(*args)
    template = Pigeon::Template.new(message)
    expect(template.render).to eq(EXPECTED_DRAFT)
    expect(template.render_without_signature).to eq(TOP_HALF)
  end
end
