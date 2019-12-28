require "pstore"

module Pigeon
  class Storage
    def self.reset
      @current.implode if @current
      @current = nil
    end

    def self.current
      @current ||= self.new
    end

    def message_count
      store.transaction do
        store[MESG_NS] ||= {}
        store[MESG_NS].count
      end
    end

    def save_message(msg)
      store.transaction do
        store[MESG_NS] ||= {}
        store[MESG_NS][msg.depth || -100] = msg
      end
    end

    def set_config(key, value)
      store.transaction do
        store[CONF_NS] ||= {}
        store[CONF_NS][key] = value
      end
    end

    def delete_config(key)
      store.transaction do
        (store[CONF_NS] || {}).delete(key)
      end
    end

    def get_config(key)
      store.transaction(true) do
        (store[CONF_NS] || {})[key]
      end
    end

    def set_blob(data)
      hex_digest = Digest::SHA256.hexdigest(data)
      store.transaction do
        store[BLOB_NS] ||= {}
        store[BLOB_NS][hex_digest] = data
      end

      [BLOB_SIGIL, hex_digest, BLOB_FOOTER].join("")
    end

    def get_blob(hex_digest)
      hd = hex_digest.gsub(BLOB_SIGIL, "").gsub(BLOB_FOOTER, "")
      store.transaction(true) do
        store[BLOB_NS] ||= {}
        store[BLOB_NS][hd]
      end
    end

    def add_peer(identity)
      path = KeyPair.strip_headers(identity)
      store.transaction do
        store[PEER_NS] ||= Set.new
        store[PEER_NS].add(identity)
      end
      identity
    end

    def remove_peer(identity)
      path = KeyPair.strip_headers(identity)
      store.transaction do
        store[PEER_NS] ||= Set.new
        store[PEER_NS].delete(identity)
      end
      identity
    end

    def block_peer(identity)
      remove_peer(identity)
      store.transaction do
        store[BLCK_NS] ||= Set.new
        store[BLCK_NS].add(identity)
      end
      identity
    end

    def all_peers
      store.transaction(true) do
        (store[PEER_NS] || Set.new).to_a
      end
    end

    def all_blocks
      store.transaction(true) do
        (store[BLCK_NS] || Set.new).to_a
      end
    end

    def implode
      @store.transaction do
        @store.roots.map do |x|
          store.delete(x)
        end
      end
    end

    private

    def store
      @store ||= PStore.new(PIGEON_DB_PATH)
    end
  end
end
