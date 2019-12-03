require "digest"

module Pigeon
  class Message
    NAME_OF_DRAFT = "HEAD.draft"
    OUTBOX_PATH = File.join(".pigeon", "user")

    attr_reader :author, :kind, :prev, :body, :depth, :signature

    def self.create(kind:, prev: nil, body: {})
      self.new(author: KeyPair.current.public_key,
               kind: kind,
               prev: prev,
               body: body).save
    end

    def initialize(author:, kind:, prev: nil, body: {})
      @author = author
      @kind = kind
      @prev = prev
      @body = body
      @depth = calculate_depth
      @prev = previous_message ? previous_message.signature : "NONE"
    end

    def self.current
      # TODO: Handle find-or-create logic.
      @current ||= Marshal.load(Pigeon::Storage.current.get_config(NAME_OF_DRAFT))
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

    def sign
      @signature = calculate_signature
      file_path = path_to_message_number(@depth)
      self.freeze
      File.write(file_path, Marshal.dump(self))
      Pigeon::Storage.current.delete_config(NAME_OF_DRAFT)
      self
    end

    def save
      Pigeon::Storage.current.set_config(NAME_OF_DRAFT, Marshal.dump(self))
      self
    end

    private

    def calculate_signature
      template = Template.new(self)
      string = template.render_without_signature
      KeyPair.current.sign(string)
    end

    def path_to_message_number(n)
      File.join(".pigeon", "user", "#{n.to_s.rjust(7, "0")}.pigeon")
    end

    def previous_message
      if @depth.nil?
        raise "Could not load @depth"
      end

      if @previous_message
        return @previous_message
      end

      if @depth == 1
        return @previous_message = nil
      end

      path = path_to_message_number(@depth - 1)
      @previous_message = Marshal.load(File.read(path))
    end

    def calculate_depth
      Dir[OUTBOX_PATH].count
    end

    def message_id # I need this to calculate `prev`.
      raise "NO!" unless @signature && !@signature.downcase.include?("draft")
      Digest::SHA256.digest(self.render)
    end
  end
end
