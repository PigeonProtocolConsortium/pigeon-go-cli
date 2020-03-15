require "erb"

module Pigeon
  # Wrapper around a message to perform string templating.
  # Renders a string that is a Pigeon-compliant message.
  class MessageSerializer
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
      author = message.author.public_key
      body = message.body
      depth = message.depth
      kind = message.kind
      prev = message.prev || EMPTY_MESSAGE
      signature = message.signature

      ERB.new(template).result(binding)
    end
  end
end
