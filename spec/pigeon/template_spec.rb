require "spec_helper"

RSpec.describe Pigeon::MessageSerializer do
  SHIM_ATTRS = %i[author body kind depth prev signature lipmaa].freeze
  MessageShim = Struct.new(*SHIM_ATTRS)
  TOP_HALF = [
    "author FAKE_AUTHOR",
    "\ndepth 23",
    "\nkind FAKE_KIND",
    "\nlipmaa 22",
    "\nprev NONE",
    "\n\nfoo:\"bar\"\n\n",
  ].join("")
  BOTTOM_HALF = "signature XYZ.sig.sha256"
  EXPECTED_DRAFT = TOP_HALF + BOTTOM_HALF

  class FakeLocalIdentity
    def self.multihash
      "FAKE_AUTHOR"
    end
  end

  it "renders a draft" do
    params = {
      author: FakeLocalIdentity,
      body: { foo: "bar".inspect },
      kind: "FAKE_KIND",
      depth: 23,
      prev: nil,
      signature: "XYZ.sig.sha256",
      lipmaa: 22,
    }.values
    message = MessageShim.new(*params)
    template = Pigeon::MessageSerializer.new(message)
    expect(template.render).to eq(EXPECTED_DRAFT)
    expect(template.render_without_signature).to eq(TOP_HALF)
  end
end
