require "digest"

module Pigeon
  class Draft
    attr_accessor :signature, :prev, :lipmaa, :kind, :depth,
                  :body, :author

    def initialize(kind:, body: {}, db:)
      @signature = Pigeon::NOTHING
      @prev = Pigeon::NOTHING
      @kind = kind
      @depth = -1
      @body = body
      @author = Pigeon::NOTHING
      @lipmaa = Pigeon::NOTHING
    end

    def [](key)
      self.body[key]
    end

    # TODO: This is a wonky API
    def put(db, key, value)
      raise STRING_KEYS_ONLY unless key.is_a?(String)

      case value[0]
      when BLOB_SIGIL, MESSAGE_SIGIL, IDENTITY_SIGIL, STRING_SIGIL
        self.body[key] = value
      else
        # If users passes a string and forgets to append
        # the string sigil (\"), we add it for them.
        # This might be a bad or good idea. Not sure yet.
        self.body[key] = value.inspect
      end
      db.save_draft(self)
      return self.body[key]
    end

    def render_as_draft
      DraftSerializer.new(self).render
    end
  end
end
