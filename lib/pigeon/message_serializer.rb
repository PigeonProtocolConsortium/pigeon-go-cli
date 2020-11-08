require "erb"

module Pigeon
  # Wrapper around a message to perform string templating.
  # Renders a string that is a Pigeon-compliant message.
  class MessageSerializer
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

    attr_reader :message

    def do_render(template)
      author = message.author.multihash
      body = message.body
      depth = message.depth
      kind = message.kind
      prev = message.prev || NOTHING
      signature = message.signature

      ERB.new(template).result(binding)
    end
  end
end
