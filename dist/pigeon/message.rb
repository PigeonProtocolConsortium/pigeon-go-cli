require "digest"

module Pigeon
  class Message
    attr_reader :author, :kind, :body, :signature, :depth, :prev

    class VerificationError < StandardError; end

    VERFIY_ERROR = "Expected field `%s` to equal %s, got: %s"
    # Author a new message.
    def self.publish(draft)
      author = LocalIdentity.current
      depth = Pigeon::Storage
        .current
        .get_message_count_for(author.public_key)
      count = store.get_message_count_for(author.public_key)
      prev = store.get_message_by_depth(author.public_key, count - 1)
      msg = self.new(author: author,
                     kind: draft.kind,
                     body: draft.body,
                     depth: depth,
                     prev: prev)
      msg.save!
      draft.discard
      msg
    end

    # Store a message that someone (not the LocalIdentity)
    # has authored.
    def self.ingest(author:, body:, depth:, kind:, prev:, signature:)
      new(author: RemoteIdentity.new(author),
          kind: kind,
          body: body,
          prev: prev,
          signature: signature,
          depth: depth)
    end

    def render
      template.render.chomp
    end

    def multihash
      sha256 = Base64.urlsafe_encode64(Digest::SHA256.digest(self.render))
      "#{MESSAGE_SIGIL}#{sha256}#{BLOB_FOOTER}"
    end

    def save!
      return store.find_message(multihash) if store.message?(multihash)
      calculate_signature
      verify_depth_prev_and_depth
      verify_signature
      self.freeze
      store.save_message(self)
      self
    end

    private

    def assert(field, actual, expected)
      unless actual == expected
        message = VERFIY_ERROR % [field, actual || "nil", expected || "nil"]
        raise VerificationError, message
      end
    end

    def verify_depth_prev_and_depth
      count = store.get_message_count_for(author.public_key)
      expected_prev = store.get_message_by_depth(author.public_key, count - 1) || Pigeon::EMPTY_MESSAGE
      assert("depth", depth, count)
      assert("prev", prev, expected_prev)
    end

    def verify_signature
      tpl = template.render_without_signature
      Helpers.verify_string(author, signature, tpl)
    end

    def initialize(author:, kind:, body:, depth:, prev:, signature: nil)
      raise MISSING_BODY if body.empty?
      @author = author
      @body = body
      @depth = depth
      @kind = kind
      @prev = prev || Pigeon::EMPTY_MESSAGE
      @signature = signature
    end

    def calculate_signature
      return if @signature
      #TODO: Verify that the author is Pigeon::LocalIdentity.current?
      @signature = author.sign(template.render_without_signature)
    end

    def template
      MessageSerializer.new(self)
    end

    def self.store
      Pigeon::Storage.current
    end

    def store
      self.class.store
    end
  end
end
