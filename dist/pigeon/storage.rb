require "pstore"

module Pigeon
  class Storage
    PIGEON_DB_PATH = File.join("db.pigeon")

    ROOT_NS = ".pigeon"
    CONF_NS = "conf"
    BLOB_NS = "blobs"
    PEER_NS = "peers"
    USER_NS = "user"
    BLCK_NS = "blocked"

    BLOB_HEADER = "&"
    BLOB_FOOTER = ".sha256"

    def self.current
      @current ||= self.new
    end

    def initialize
      create_pstore unless initialized?
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

      [BLOB_HEADER, hex_digest, BLOB_FOOTER].join("")
    end

    def get_blob(hex_digest)
      hd = hex_digest.gsub(BLOB_HEADER, "").gsub(BLOB_FOOTER, "")
      store.transaction(true) do
        store[BLOB_NS] ||= {}
        store[BLOB_NS][hex_digest]
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
      # remove_peer(identity)
      # path = KeyPair.strip_headers(identity)
      # FileUtils.touch(File.join(block_dir, path))
      # identity
    end

    def all_peers
      store.transaction(true) do
        (store[PEER_NS] || Set.new).to_a
      end
    end

    def all_blocks
      Dir[File.join(block_dir, "*")]
        .map { |x| File.split(x).last }
        .map { |x| KeyPair.add_headers(x) }
    end

    private

    def initialized?
      File.file?(PIGEON_DB_PATH)
    end

    def create_pstore
      FileUtils.rm(PIGEON_DB_PATH) if File.file?(PIGEON_DB_PATH)
    end

    def store
      @store ||= PStore.new(PIGEON_DB_PATH)
    end
  end
end
