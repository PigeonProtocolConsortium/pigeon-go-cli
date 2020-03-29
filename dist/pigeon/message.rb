require "digest"

module Pigeon
  class Message
    attr_reader :author, :kind, :body, :signature, :depth, :prev

    class VerificationError < StandardError; end

    VERFIY_ERROR = "Expected field `%s` to equal %s, got: %s"
    # Author a new message.
    def self.publish(draft, author: LocalIdentity.current)
      msg = self.new(author: LocalIdentity.current,
                     kind: draft.kind,
                     body: draft.body,
                     depth: Pigeon::Storage.current.get_message_count_for(LocalIdentity.current))
      # We might need to add conditional logic here
      # Currently YAGNI since all Drafts we handle today
      # are authored by LocalIdentity.current
      draft.discard
      msg
    end

    # Store a message that someone (not the LocalIdentity)
    # has authored.
    def self.ingest(author:, body:, depth:, kind:, prev:, signature:)
      new(author: RemoteIdentity.new(author),
          kind: kind,
          body: body,
          signature: signature,
          depth: depth)
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
      self.freeze
    end

    private

    def assert(field, actual, expected)
      unless actual == expected
        message = VERFIY_ERROR % [field, actual, expected || "nil"]
        raise VerificationError, message
      end
    end

    def verify_depth_prev_and_depth
      count = Pigeon::Storage.current.get_message_count_for(self.author)
      if count == nil
        assert("depth", self.depth, 0)
        assert("prev", self.prev, nil)
      else
        # Make sure the `depth` prop is equal to count + 1
        # Make sure the `prev` prop is equal to
        #   message_by_depth(author, (depth - 1))
        raise "WIP"
      end
    end

    def verify_signature
      tpl = template.render_without_signature
      Helpers.verify_string(author, signature, tpl)
    end

    def initialize(author:, kind:, body:, signature: nil, depth:)
      raise MISSING_BODY if body.empty?
      @author = author
      @kind = kind
      @body = body
      # Side effects in a constructor? Hmm...
      @depth = depth
      @signature = signature || calculate_signature
      @prev = store.get_message_by_depth(@author.public_key, @depth - 1)
      verify!
      store.save_message(self)
    end

    def template
      MessageSerializer.new(self)
    end

    def calculate_signature
      @author.sign(template.render_without_signature)
    end

    def store
      Pigeon::Storage.current
    end
  end
end
