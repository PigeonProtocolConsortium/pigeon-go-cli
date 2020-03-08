require "digest"

module Pigeon
  class Message
    attr_reader :author, :kind, :body, :signature, :depth, :prev

    def self.from_draft(draft, author: KeyPair.current)
      msg = self.new(author: KeyPair.current,
                     kind: draft.kind,
                     body: draft.body)
      # We might need to add conditional logic here
      # Currently YAGNI since all Drafts we handle today
      # are authored by KeyPair.current
      draft.discard
      msg
    end

    def render
      Serializer.new(self).render
    end

    private

    def initialize(author:, kind:, body:)
      raise "BODY CANT BE EMPTY" if body.empty?
      @author = author
      @kind = kind
      @body = body
      # Side effects in a constructor? Hmm...
      store = Pigeon::Storage.current
      @signature = calculate_signature
      @depth = store.message_count
      @prev = store.get_message_by_depth(@author, @depth - 1)
      self.freeze
      store.save_message(self)
    end

    def calculate_signature
      template = Serializer.new(self)
      string = template.render_without_signature
      KeyPair.current.sign(string)
    end
  end
end
