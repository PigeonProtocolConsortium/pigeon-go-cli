require "erb"

module Pigeon
  # Wrapper around a message to perform string templating.
  # Renders a string that is a Pigeon-compliant message.
  class Template
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
      depth = message.depth || "NONE"
      prev = message.prev || "NONE"
      signature = message.signature || "NONE"

      ERB.new(template).result(binding)
    end
  end
end
