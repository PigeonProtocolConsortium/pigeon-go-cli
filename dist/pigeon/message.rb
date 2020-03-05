require "digest"

module Pigeon
  class Message
    attr_reader :author, :kind, :body, :signature

    def self.from_draft(draft, author: KeyPair.current)
      self.new(author: KeyPair.current,
               kind: draft.kind,
               body: draft.body).save
    end

    def initialize(author:, kind:, body: )
      @author = author
      @kind = kind
      @body = body
    end

    def save
      Pigeon::Storage.current.set_config(CURRENT_DRAFT, self)
      self
    end

    def sign
      @signature = calculate_signature
      @depth = Pigeon::Storage.current.message_count
      @saved = true
      self.freeze
      Pigeon::Storage.current.save_message(self)
      Pigeon::Message.reset_current
      @signature
    end

    def render
      Template.new(self).render
    end

    def depth
      calculate_depth
    end

    def prev
      if @saved
        previous_message
      else
        raise Pigeon::PREV_REQUIRES_SAVE
      end
    end

    private

    def calculate_signature
      template = Template.new(self)
      string = template.render_without_signature
      KeyPair.current.sign(string)
    end

    def previous_message
      raise "TODO - I need to create a `Pigeon::Index` class or something. " \
            "need a way to index messages by: signature, depth"
    end
  end
end
