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

    def render_as_draft
      DraftSerializer.new(self).render
    end
  end
end
