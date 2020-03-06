require "digest"

module Pigeon
  class Draft
    attr_reader :kind, :body

    def self.create(kind:, body: {})
      self.new(kind: kind, body: body).save
    end

    def self.current
      @current ||=
        (Pigeon::Storage.current.get_config(CURRENT_DRAFT) || new.save)
    end

    def self.reset_current
      Pigeon::Storage.current.set_config(CURRENT_DRAFT, nil)
      @current = nil
    end

    def initialize(kind:, body: {})
      @kind = kind
      @body = body
    end

    def [](key)
      self.body[key]
    end

    def []=(key, value)
      case value[0]
      when BLOB_SIGIL, SIGNATURE_SIGIL, IDENTITY_SIGIL, STRING_SIGIL
        self.body[key] = value
      else
        self.body[key] = value.inspect
      end
      self.save
      return self.body[key]
    end

    # NOT the same thing as #sign/0
    def save
      Pigeon::Storage.current.set_config(CURRENT_DRAFT, self)
      self
    end

    def render
      DraftTemplate.new(self).render
    end
  end
end
