require "digest"

module Pigeon
  class Message
    attr_reader :author, :kind, :body, :signature, :depth, :prev

    def self.from_draft(draft, author: KeyPair.current)
      self.new(author: KeyPair.current,
               kind: draft.kind,
               body: draft.body)
    end

    def sign
      store = Pigeon::Storage.current
      @signature = calculate_signature
      @depth = store.message_count
      @prev = store.get_message_by_depth(@depth - 1)
      self.freeze
      store.save_message(self)
      self
    end

    def render
      Template.new(self).render
    end

    private

    def initialize(author:, kind:, body:)
      @author = author
      @kind = kind
      @body = body
      # Side effects in a constructor? Hmm...
      sign
    end

    def calculate_signature
      template = Template.new(self)
      string = template.render_without_signature
      KeyPair.current.sign(string)
    end
  end
end
