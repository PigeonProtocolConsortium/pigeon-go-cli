require "digest"

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
      string = Template.new(self).render_without_signature
      KeyPair.current.sign(string)
    end

    def path_to_message_number(n)
      File.join(".pigeon", "user", "#{n.to_s.rjust(7, "0")}.pigeon")
    end

    def previous_message
      raise "Could not load @depth" unless @depth
      if (@depth == 1)
        return nil
      else
        Marshal.load(File.read(path_to_message_number(@depth - 1)))
      end
    end

    def calculate_depth
      Dir[OUTBOX_PATH].count
    end

    def sign
      # Set @depth
      @depth = calculate_depth
      @prev = previous_message ? previous_message.signature : "".inspect
      @signature = calculate_signature
      file_path = path_to_message_number(@depth)
      self.freeze
      File.write(file_path, Marshal.dump(self))
      self
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
