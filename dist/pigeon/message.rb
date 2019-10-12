module Pigeon
  class Message
    NAME_OF_DRAFT = "HEAD"

    attr_reader :author,
                :kind,
                :previous,
                :body,
                :sequence, # Maybe not?
                :timestamp, # Maybe not?
                :signature # Maybe not?

    def initialize(author:,
                   kind:,
                   previous: nil,
                   body: [],
                   timestamp: Time.now.to_i)
      @author = author
      @kind = kind
      @previous = previous
      @body = body
      @timestamp = timestamp
    end

    def self.create(kind:, previous: nil, body: [])
      # instantiate
      msg = self.new(author: KeyPair.current.public_key,
                     kind: kind,
                     previous: previous,
                     body: body)
      # Save to disk as HEAD
      Pigeon::Storage.current.set_config(NAME_OF_DRAFT, Marshal.dump(msg))
    end
  end
end
