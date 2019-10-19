module Pigeon
  class Message
    NAME_OF_DRAFT = "HEAD.draft"

    attr_reader :author,
                :kind,
                :prev,
                :body,
                :depth,
                :timestamp, # Maybe not?
                :signature # Maybe not?

    def initialize(author:,
                   kind:,
                   prev: nil,
                   body: [],
                   timestamp: Time.now.to_i)
      @author = author
      @kind = kind
      @prev = prev
      @body = body
      @timestamp = timestamp
    end

    def self.create(kind:, prev: nil, body: {})
      # instantiate
      msg = self.new(author: KeyPair.current.public_key,
                     kind: kind,
                     prev: prev,
                     body: body)
      # Save to disk as HEAD
      Pigeon::Storage.current.set_config(NAME_OF_DRAFT, Marshal.dump(msg))
      msg
    end

    def serialize
      Template.new(self).render
    end
  end
end
