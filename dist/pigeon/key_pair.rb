module Pigeon
  # This is a wrapper around the `ed25519` gem to
  # help us maintain our sanity when the Gem's API
  # changes.
  class KeyPair
    HEADER, FOOTER = ["@", ".ed25519"]

    def self.strip_headers(identity)
      identity.sub(HEADER, "").sub(FOOTER, "")
    end

    def self.add_headers(urlsafe_b64_no_headers)
      [HEADER, urlsafe_b64_no_headers, FOOTER].join("")
    end

    # `seed` is a 32-byte seed value from which
    #  the key should be derived
    def initialize(seed = SecureRandom.random_bytes(Ed25519::KEY_SIZE))
      @seed = seed
      @raw_key = Ed25519::SigningKey.new(seed)
    end

    def private_key
      @private_key ||= Base64.urlsafe_encode64(@seed)
    end

    def public_key
      bytes = @raw_key.verify_key.to_bytes
      b64 = Base64.urlsafe_encode64(bytes)

      @public_key ||= KeyPair.add_headers(b64)
    end

    def to_h
      {
        public_key: public_key,
        private_key: private_key,
      }
    end

    def save!
      self.to_h.map do |k, v|
        Pigeon::Storage.current.set_conf(k, v)
      end
    end
  end
end
