module Pigeon
  class Message
    NAME_OF_DRAFT = "HEAD.draft"
    OUTBOX_PATH = File.join(".pigeon", "user")

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
      self.new(author: KeyPair.current.public_key,
               kind: kind,
               prev: prev,
               body: body).save
    end

    def self.current
      # TODO: Handle find-or-create logic.
      @current ||= Marshal.load(Pigeon::Storage.current.get_config(NAME_OF_DRAFT))
    end

    def calculate_signature
      puts "========== TODO"
      "FIX_ASAP_!"
    end

    def path_to_message_numbe(n)
      File.join(".pigeon", "user", "#{n.to_s.rjust(7, "0")}.pigeon")
    end

    def sign
      # Set @depth
      @depth = (Dir[OUTBOX_PATH].count - 1)
      @signature = calculate_signature

      # Create a file in ".pigeon/user/#{ @depth.rjust(7, "0") }".pigeon
      file_path = path_to_message_numbe(@depth)
      binding.pry
      # calculate prev
      @prev = "HOW WILL I DO THIS?"
      # Store to disk
      self.save
      # return self
    end

    def save
      Pigeon::Storage.current.set_config(NAME_OF_DRAFT, Marshal.dump(self))
      self
    end

    def render
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
