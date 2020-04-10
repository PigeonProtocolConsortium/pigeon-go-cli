require "digest"

module Pigeon
  class Draft
    attr_reader :signature, :prev, :kind, :internal_id,
                :depth, :body, :author

    def self.create(kind:, body: {})
      self.new(kind: kind, body: body).save_as_draft
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
      @signature = Pigeon::EMPTY_MESSAGE
      @prev = Pigeon::EMPTY_MESSAGE
      @kind = kind
      @depth = -1
      @body = body
      @author = Pigeon::EMPTY_MESSAGE
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
      self.save_as_draft
      return self.body[key]
    end

    def save_as_draft
      Pigeon::Storage.current.set_config(CURRENT_DRAFT, self)
      self
    end

    # Author a new message.
    def publish
      template = MessageSerializer.new(self)

      @author = LocalIdentity.current
      @depth = store.get_message_count_for(author.multihash)
      @prev = store.get_message_by_depth(author.multihash, @depth - 1)
      @signature = author.sign(template.render_without_signature)

      candidate = template.render
      tokens = Lexer.tokenize(candidate)
      message = Parser.parse(tokens)[0]
      self.discard
      message
    end

    def render_as_draft
      DraftSerializer.new(self).render
    end

    def store
      Pigeon::Storage.current
    end
  end
end
