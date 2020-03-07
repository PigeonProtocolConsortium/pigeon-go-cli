require "erb"

module Pigeon
  # Wrapper around a Pigeon::Draft to perform string templating.
  # Renders a string that contains most (but not all) of a Pigeon message.
  class DraftSerializer
    attr_reader :message

    def initialize(message)
      @message = message
    end

    def render
      body = message.body
      kind = message.kind
      author = DRAFT_PLACEHOLDER
      depth = DRAFT_PLACEHOLDER
      prev = DRAFT_PLACEHOLDER
      signature = DRAFT_PLACEHOLDER

      ERB.new([HEADER_TPL, BODY_TPL].join("")).result(binding)
    end
  end
end
