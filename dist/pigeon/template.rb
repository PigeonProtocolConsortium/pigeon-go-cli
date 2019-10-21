require "erb"

module Pigeon
  # Wrapper around a message to perform string templating.
  # Renders a string that is a Pigeon-compliant message.
  class Template
    TPL_DIR = "views"

    HEADER_TPL = File.read(File.join(TPL_DIR, "1_header.erb")).sub("\n", "")
    BODY_TPL = File.read(File.join(TPL_DIR, "2_body.erb")).sub("\n", "")
    FOOTER_TPL = File.read(File.join(TPL_DIR, "3_footer.erb")).sub("\n", "")

    COMPLETE_TPL = [HEADER_TPL, BODY_TPL, FOOTER_TPL].join("")

    attr_reader :message

    def initialize(message)
      @message = message
    end

    def render
      do_render(COMPLETE_TPL)
    end

    def render_without_signature
      do_render([HEADER_TPL, BODY_TPL].join(""))
    end

    private

    def do_render(template)
      author = message.author
      body = message.body
      kind = message.kind
      depth = message.depth || "DRAFT"
      prev = message.prev || "DRAFT"
      signature = message.signature || "DRAFT"

      ERB.new(COMPLETE_TPL).result(binding)
    end
  end
end
