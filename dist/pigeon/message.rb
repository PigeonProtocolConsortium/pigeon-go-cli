require "digest"

module Pigeon
  class Message
    attr_reader :author, :kind, :body, :signature

    def self.create(kind:, body: {})
      self.new(author: KeyPair.current.public_key,
               kind: kind,
               body: body).save
    end

    def initialize(author:, kind:, body: {})
      @author = author
      @kind = kind
      @body = body
      @depth = nil # Set at save time
    end

    def append(key, value)
      puts "TODO: Add #[] / #[]= methods"
      puts "TODO: Add #readonly? method and disallow edits after save"
      # TODO: Sanitize, validate inputs.
      case value[0]
      when BLOB_SIGIL, SIGNATURE_SIGIL, IDENTITY_SIGIL, STRING_SIGIL
        self.body[key] = value
      else
        self.body[key] = value.inspect
      end
      self.save
      return self.body[key]
    end

    def self.current
      @current ||=
        (Pigeon::Storage.current.get_config(CURRENT_DRAFT) || new.save)
    end

    def self.reset_current
      @current = nil
    end

    def save
      Pigeon::Storage.current.set_config(CURRENT_DRAFT, self)
      self
    end

    def sign
      @signature = calculate_signature
      @depth = Pigeon::Storage.current.message_count
      @saved = true
      self.freeze
      Pigeon::Storage.current.save_message(self)
      Pigeon::Message.reset_current
      @signature
    end

    def render
      Template.new(self).render
    end

    def depth
      calculate_depth
    end

    def prev
      if @saved
        previous_message
      else
        raise Pigeon::PREV_REQUIRES_SAVE
      end
    end

    def saved?
      @saved == true
    end

    private

    def calculate_signature
      template = Template.new(self)
      string = template.render_without_signature
      KeyPair.current.sign(string)
    end

    def previous_message
      raise "TODO - I need to create a `Pigeon::Index` class or something. " \
            "need a way to index messages by: signature, depth"
      # if @depth.nil?
      #   raise "Could not load @depth"
      # end

      # if @previous_message
      #   return @previous_message
      # end

      # if @depth == 1
      #   return @previous_message = nil
      # end

      # path = path_to_message_number(@depth - 1)
      # @previous_message = Marshal.load(File.read(path))
    end

    def calculate_depth
      raise "Don't do this- read from the index. Also, crash if message is not saved."
      @depth || Pigeon::Storage.current.message_count
    end

    def message_id # I need this to calculate `prev`.
      # raise "NO!" unless @signature && !@signature.downcase.include?("draft")
      # Digest::SHA256.digest(self.render)
    end
  end
end
