module Pigeon
  # This is a wrapper around the `ed25519` gem to
  # help us maintain our sanity when the Gem's API
  # changes.
  class KeyPair
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
    end

    def private_key
      @private_key ||= Base64.urlsafe_encode64(@seed)
    end

    def public_key
      bytes = raw_key.verify_key.to_bytes
      b64 = Base64.urlsafe_encode64(bytes)

      @public_key ||= KeyPair.add_headers(b64)
    end

    def sign(string)
      hex = raw_key.sign(string)
      b64 = Base64.urlsafe_encode64(hex)
      return b64 + ".sig.ed25519"
    end

    def save!
      Pigeon::Storage.current.set_config(SEED_CONFIG_KEY, @seed)
      self
    end

    private

    def self.strip_headers(identity)
      identity.sub(HEADER, "").sub(FOOTER, "")
    end

    def self.add_headers(urlsafe_b64_no_headers)
      [HEADER, urlsafe_b64_no_headers, FOOTER].join("")
    end

    def raw_key
      @raw_key ||= Ed25519::SigningKey.new(@seed)
    end
  end
end
