require "digest"

module Pigeon
  class Draft
    attr_accessor :signature, :prev, :lipmaa, :kind, :depth,
                  :body, :author

    def initialize(kind:, body: {})
      @signature = Pigeon::NOTHING
      @prev = Pigeon::NOTHING
      @kind = kind
      @depth = -1
      @body = {}
      @author = Pigeon::NOTHING
      @lipmaa = Pigeon::NOTHING
      body.to_a.map { |(k, v)| self[k] = v }
    end

    def [](key)
      body[key]
    end

    def []=(key, value)
      raise STRING_KEYS_ONLY unless key.is_a?(String)

      case value[0]
      when BLOB_SIGIL, MESSAGE_SIGIL, IDENTITY_SIGIL, STRING_SIGIL
        body[key] = value
      else
        body[key] = value.inspect
      end
    end

    def render_as_draft
      DraftSerializer.new(self).render
    end
  end
end
