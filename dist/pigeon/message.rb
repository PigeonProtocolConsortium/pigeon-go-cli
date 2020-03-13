require "digest"

module Pigeon
  class Message
    attr_reader :author, :kind, :body, :signature, :depth, :prev

    def self.publish(draft, author: KeyPair.current)
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
      template.render.chomp
    end

    def multihash
      sha256 = Base64.urlsafe_encode64(Digest::SHA256.hexdigest(self.render))
      "#{MESSAGE_SIGIL}#{sha256}#{BLOB_FOOTER}"
    end

    private

    def template
      @template ||= MessageSerializer.new(self)
    end

    def initialize(author:, kind:, body:, signature: nil)
      raise "BODY CANT BE EMPTY" if body.empty?
      @author = author
      @kind = kind
      @body = body
      # Side effects in a constructor? Hmm...
      store = Pigeon::Storage.current
      @depth = store.message_count
      @signature = signature || calculate_signature
      @prev = store.get_message_by_depth(@author, @depth - 1)
      self.freeze
      store.save_message(self)
    end

    def calculate_signature
      @author.sign(template.render_without_signature)
    end
  end
end
