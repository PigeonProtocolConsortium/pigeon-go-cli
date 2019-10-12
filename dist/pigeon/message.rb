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

    def initialize(author:, kind:, previous: nil, body: [])
      @author = author
      @kind = kind
      @previous = previous
      @body = body
    end

    def self.create(author:, kind:, previous: nil, body: [])
      # instantiate
      msg = self.new(author: author,
                     kind: kind,
                     previous: previous,
                     body: body)
      # Save to disk as HEAD
      Pigeon::Storage.set_config(NAME_OF_DRAFT, msg.dump)
    end

    protected

    def dump
      string = Marshal.dump(self)
    end
  end
end
