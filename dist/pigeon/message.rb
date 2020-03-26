require "digest"

module Pigeon
  class Message
    attr_reader :author, :kind, :body, :signature, :depth, :prev
    class VerificationError < StandardError; end
    VERFIY_ERROR = "Expected field %s to equal %s. Got: %s"
    # Author a new message.
    def self.publish(draft, author: LocalIdentity.current)
      msg = self.new(author: LocalIdentity.current,
                     kind: draft.kind,
                     body: draft.body)
      # We might need to add conditional logic here
      # Currently YAGNI since all Drafts we handle today
      # are authored by LocalIdentity.current
      draft.discard
      msg
    end

    # Store a message that someone (not the LocalIdentity)
    # has authored.
    def self.ingest(author:, body:, depth:, kind:, prev:, signature:)
      message = new(author: RemoteIdentity.new(author),
                    kind: kind,
                    body: body,
                    signature: signature)
      message.verify!
      message.save
    end

    def render
      template.render.chomp
    end

    def multihash
      sha256 = Base64.urlsafe_encode64(Digest::SHA256.hexdigest(self.render))
      "#{MESSAGE_SIGIL}#{sha256}#{BLOB_FOOTER}"
    end

    def verify!
      verify_depth_prev_and_depth
      verify_signature
    end

    private

    def assert(field, actual, expected)
      unless actual == expected
        message = VERFIY_ERROR % [field, actual, expected]
        raise VerificationError, message
      end
    end

    def verify_depth_prev_and_depth
      store = Pigeon::Storage.current
      count = store.get_message_count_for(self.author)
      if count == 0
        assert("depth", self.depth, 0)
        assert("prev", self.prev, nil)
      else
        # Make sure the `depth` prop is equal to count + 1
        # Make sure the `prev` prop is equal to
        #   message_by_depth(author, (depth - 1))
        binding.pry
      end
    end

    def verify_signature
      author.verify(signature, template.render_without_signature)
    end

    def initialize(author:, kind:, body:, signature: nil)
      raise MISSING_BODY if body.empty?
      @author = author
      @kind = kind
      @body = body
      # Side effects in a constructor? Hmm...
      store = Pigeon::Storage.current
      @depth = store.message_count
      @signature = signature || calculate_signature
      @prev = store.get_message_by_depth(@author.public_key, @depth - 1)
      self.freeze
      store.save_message(self)
    end

    def template
      MessageSerializer.new(self)
    end

    def calculate_signature
      @author.sign(template.render_without_signature)
    end
  end
end
