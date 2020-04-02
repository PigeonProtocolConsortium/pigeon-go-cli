require "digest"

module Pigeon
  class Draft
    attr_reader :kind, :body, :internal_id

    def self.create(kind:, body: {})
      self.new(kind: kind, body: body).save
    end

    def self.current
      Pigeon::Storage.current.get_config(CURRENT_DRAFT) or raise NO_DRAFT_FOUND
    end

    def self.reset_current
      Pigeon::Storage.current.set_config(CURRENT_DRAFT, nil)
    end

    def discard
      if Draft.current&.internal_id == @internal_id
        Draft.reset_current
      end
    end

    def initialize(kind:, body: {})
      @kind = kind
      @body = body
      @internal_id = SecureRandom.uuid
    end

    def [](key)
      self.body[key]
    end

    def []=(key, value)
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
      self.save
      return self.body[key]
    end

    def save
      Pigeon::Storage.current.set_config(CURRENT_DRAFT, self)
      self
    end

    def render
      DraftSerializer.new(self).render
    end
  end
end
