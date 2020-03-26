module Pigeon
  # A public and private key pair that represents the local
  # user who "owns" the database.
  #
  # Provides a wrapper around the `ed25519` gem to
  # help us maintain our sanity when the Gem's API
  # changes.
  class LocalIdentity
    def self.reset
      @current = nil
    end

    def self.current
      if @current
        @current
      else
        key = Pigeon::Storage.current.get_config(SEED_CONFIG_KEY)
        @current = (key ? self.new(key) : self.new).save!
      end
    end

    # `seed` is a 32-byte seed value from which
    #  the key should be derived
    def initialize(seed = SecureRandom.random_bytes(Ed25519::KEY_SIZE))
      @seed = seed
      @signing_key = Ed25519::SigningKey.new(@seed)
    end

    def private_key
      @private_key ||= Base64.urlsafe_encode64(@seed)
    end

    def public_key
      bytes = @signing_key.verify_key.to_bytes
      b64 = Base64.urlsafe_encode64(bytes)

      @public_key ||= [HEADER, b64, FOOTER].join("")
    end

    def sign(string)
      hex = @signing_key.sign(string)
      b64 = Base64.urlsafe_encode64(hex)
      return b64 + SIG_FOOTER
    end

    def verify(signature, string)
      raise "TODO"
    end

    def save!
      Pigeon::Storage.current.set_config(SEED_CONFIG_KEY, @seed)
      self
    end

    private

    def self.strip_headers(identity)
      identity.sub(HEADER, "").sub(FOOTER, "")
    end
  end
end