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
      self.new(author: KeyPair.current.public_key,
               kind: kind,
               prev: prev,
               body: body).save
    end

    def self.current
      @current ||= Marshal.load(Pigeon::Storage.current.get_config(NAME_OF_DRAFT))
    end

    def save
      Pigeon::Storage.current.set_config(NAME_OF_DRAFT, Marshal.dump(self))
      self
    end

    def serialize
      Template.new(self).render
    end

    def append(key, value)
      # TODO: Sanitize, validate inputs.
      case value[0]
      when "%", "@", "&", "\"" # TODO: Use constants, not literals.
        self.body[key] = value
      else
        self.body[key] = value.inspect
      end
      self.save
      return self.body[key]
    end
  end
end
