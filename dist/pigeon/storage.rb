require "pstore"

module Pigeon
  class Storage
    def self.reset
      File.delete(PIGEON_DB_PATH) if File.file?(PIGEON_DB_PATH)
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

    def find_message(multihash)
      store.transaction(true) do
        store[MESG_NS].fetch(multihash)
      end
    end

    def find_all
      # TODO: Ability to pass an author ID to `find-all`
      author = Pigeon::KeyPair.current
      store = Pigeon::Storage.current
      all = []
      depth = -1
      last = ""
      until (last == nil) || (depth > 999999)
        last = store.get_message_by_depth(author, depth += 1)
        all.push(last) if last
      end
      return all
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

    def bootstrap
      store.transaction do
        store[DEPTH_INDEX_NS] ||= {}
        store[BLOB_NS] ||= {}
        store[CONF_NS] ||= {}
        store[MESG_NS] ||= {}
        store[BLCK_NS] ||= Set.new
        store[PEER_NS] ||= Set.new
      end
      store
    end

    private

    def store
      if @store
        return @store
      else
        @store = PStore.new(PIGEON_DB_PATH)
        bootstrap
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
