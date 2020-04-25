module Pigeon
  # A public and private key pair that represents the local
  # user who "owns" the database.
  #
  # Provides a wrapper around the `ed25519` gem to
  # help us maintain our sanity when the Gem's API
  # changes.
  class LocalIdentity
    # `seed` is a 32-byte seed value from which
    #  the key should be derived
    def initialize(seed)
      @seed = seed
      @signing_key = Ed25519::SigningKey.new(@seed)
    end

    def private_key
      @private_key ||= Helpers.b32_encode(@seed)
    end

    def multihash
      bytes = @signing_key.verify_key.to_bytes
      b64 = Helpers.b32_encode(bytes)

      @multihash ||= [IDENTITY_SIGIL, b64, IDENTITY_FOOTER].join("")
    end

    def sign(string)
      hex = @signing_key.sign(string)
      b64 = Helpers.b32_encode(hex)
      b64 + SIG_FOOTER
    end
  end
end
