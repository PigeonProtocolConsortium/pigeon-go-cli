require "digest"

module Pigeon
  class Message
    attr_reader :author, :kind, :body, :signature, :depth, :lipmaa, :prev

    class VerificationError < StandardError; end
    class MessageSizeError < StandardError; end

    VERFIY_ERROR = "Expected field `%s` to equal %s, got: %s"
    MSG_SIZE_ERROR = "Messages cannot have more than 64 keys. Got %s."

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
  end
end
