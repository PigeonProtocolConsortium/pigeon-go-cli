require "pstore"

module Pigeon
  class Storage
    def self.reset
      @current.reset_defaults if @current
      @current = nil
    end

    def self.current
      @current ||= self.new
    end

    def get_message_by_depth(author, depth)
      store.transaction do
        # Map<[author(str), depth(int)], Signature>
        store[DEPTH_INDEX_NS][[author.public_key, depth]]
      end
    end

    def message_count
      store.transaction do
        store[MESG_NS].count
      end
    end

    def save_message(msg)
      store.transaction do
        insert_and_update_index(msg)
        msg
      end
    end

    def set_config(key, value)
      store.transaction do
        store[CONF_NS][key] = value
      end
    end

    def delete_config(key)
      store.transaction do
        store[CONF_NS].delete(key)
      end
    end

    def get_config(key)
      store.transaction(true) do
        store[CONF_NS][key]
      end
    end

    def set_blob(data)
      raw_digest = Digest::SHA256.hexdigest(data)
      b64_digest = Base64.urlsafe_encode64(raw_digest)
      multihash = [BLOB_SIGIL, b64_digest, BLOB_FOOTER].join("")

      store.transaction do
        store[BLOB_NS][multihash] = data
      end

      multihash
    end

    def get_blob(blob_multihash)
      store.transaction(true) do
        store[BLOB_NS][blob_multihash]
      end
    end

    def add_peer(identity)
      path = KeyPair.strip_headers(identity)
      store.transaction do
        store[PEER_NS].add(identity)
      end
      identity
    end

    def remove_peer(identity)
      path = KeyPair.strip_headers(identity)
      store.transaction do
        store[PEER_NS].delete(identity)
      end
      identity
    end

    def block_peer(identity)
      remove_peer(identity)
      store.transaction do
        store[BLCK_NS].add(identity)
      end
      identity
    end

    def all_peers
      store.transaction(true) do
        store[PEER_NS].to_a
      end
    end

    def all_blocks
      store.transaction(true) do
        store[BLCK_NS].to_a
      end
    end

    def reset_defaults
      store.transaction do
        store[DEPTH_INDEX_NS] = {}
        store[BLOB_NS] = {}
        store[CONF_NS] = {}
        store[MESG_NS] = {}
        store[BLCK_NS] = Set.new
        store[PEER_NS] = Set.new
      end
      store
    end

    private

    def store
      if @store
        return @store
      else
        @store = PStore.new(PIGEON_DB_PATH)
        reset_defaults
      end
    end

    def insert_and_update_index(message)
      # STEP 1: Update MESG_NS, the main storage spot.
      store[MESG_NS][message.multihash] = message

      # STEP 2: Update the "message by author and depth" index
      #         this index is used to find a person's nth
      #         message
      # SECURITY AUDIT: How can we be certain the message is
      # not lying about its depth?
      key = [message.author.public_key, message.depth]
      store[DEPTH_INDEX_NS][key] = message.multihash
    end
  end
end
