require "digest"

module Pigeon
  class Message
    attr_reader :author, :kind, :body, :signature, :depth, :lipmaa, :prev

    class VerificationError < StandardError; end
    class MessageSizeError < StandardError; end

    VERFIY_ERROR = "Expected field `%s` to equal %s, got: %s"
    MSG_SIZE_ERROR = "Messages cannot have more than 64 keys. Got %s."
    # Store a message that someone (not the LocalIdentity)
    # has authored.
    def self.ingest(author:, body:, depth:, kind:, lipmaa:, prev:, signature:)
      params = { author: RemoteIdentity.new(author),
                 kind: kind,
                 body: body,
                 prev: prev,
                 lipmaa: lipmaa,
                 signature: signature,
                 depth: depth }
      # Kind of weird to use `send` but #save! is private,
      # and I don't want people calling it directly without going through the
      # lexer / parser first.
      new(**params).send(:save!)
    end

    def render
      template.render.chomp
    end

    def multihash
      tpl = self.render
      digest = Digest::SHA256.digest(tpl)
      sha256 = Helpers.b32_encode(digest)
      "#{MESSAGE_SIGIL}#{sha256}#{BLOB_FOOTER}"
    end

    private

    def save!
      return store.read_message(multihash) if store.message?(multihash)
      verify_counted_fields
      verify_signature
      self.freeze
      store.save_message(self)
      self
    end

    def assert(field, actual, expected)
      unless actual == expected
        message = VERFIY_ERROR % [field, actual || "nil", expected || "nil"]
        raise VerificationError, message
      end
    end

    def verify_counted_fields
      key_count = body.count
      if key_count > 64
        msg = MSG_SIZE_ERROR % key_count
        raise MessageSizeError, msg
      end
      count = store.get_message_count_for(author.multihash)
      expected_prev = store.get_message_by_depth(author.multihash, count - 1) || Pigeon::NOTHING
      assert("depth", count, depth)
      # TODO: Re-visit this. Our current verification method
      # is probably too strict and won't allow for partial
      # verification of feeds.
      assert("lipmaa", Helpers.lipmaa(depth), lipmaa)
      assert("prev", prev, expected_prev)
    end

    def verify_signature
      tpl = template.render_without_signature
      Helpers.verify_string(author, signature, tpl)
    end

    def initialize(author:,
                   kind:,
                   body:,
                   depth:,
                   prev:,
                   lipmaa:,
                   signature:)
      raise MISSING_BODY if body.empty?
      @author = author
      @body = body
      @depth = depth
      @kind = kind
      @prev = prev || Pigeon::NOTHING
      @lipmaa = lipmaa
      @signature = signature
    end

    def template
      MessageSerializer.new(self)
    end

    def store
      Pigeon::Storage.current
    end
  end
end
