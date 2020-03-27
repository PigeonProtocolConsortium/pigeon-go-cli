module Pigeon
  # A private key pair that represents a
  # user who "owns" the database.
  #
  # Provides a wrapper around the `ed25519` gem to
  # help us maintain our sanity when the Gem's API
  # changes.
  class RemoteIdentity
    attr_reader :public_key

    def initialize(multihash)
      @public_key = multihash
    end
  end
end
