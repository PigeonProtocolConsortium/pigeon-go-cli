require "digest"

module Pigeon
  class Draft
    attr_reader :signature, :prev, :lipmaa, :kind, :internal_id,
                :depth, :body, :author

    def discard
      if Draft.current&.internal_id == @internal_id
        Draft.reset_current
      end
    end

    def initialize(kind:, body: {}, db:)
      @db = db
      @signature = Pigeon::NOTHING
      @prev = Pigeon::NOTHING
      @kind = kind
      @depth = -1
      @body = body
      @author = Pigeon::NOTHING
      @lipmaa = Pigeon::NOTHING
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
      @db.save_draft(self)
      return self.body[key]
    end

    # Author a new message.
    def publish
      template = MessageSerializer.new(self)
      @author = LocalIdentity.current
      @depth = store.get_message_count_for(author.multihash)
      @prev = store.get_message_by_depth(author.multihash, @depth - 1)
      @lipmaa = Helpers.lipmaa(@depth)
      unsigned = template.render_without_signature
      @signature = author.sign(unsigned)
      tokens = Lexer.tokenize_unsigned(unsigned, signature)
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
