require "pstore"

module Pigeon
  class Storage
    attr_reader :path

    def initialize(path: PIGEON_DB_PATH)
      @path = path
      store.ultra_safe = true
      bootstrap
    end

    def reset
      File.delete(path) if on_disk?
      bootstrap
    end

    def add_peer(identity)
      path = Helpers.decode_multihash(identity)
      write { store[PEER_NS].add(identity) }
      identity
    end

    def remove_peer(identity)
      path = Helpers.decode_multihash(identity)
      write { store[PEER_NS].delete(identity) }
      identity
    end

    def block_peer(identity)
      remove_peer(identity)
      write { store[BLCK_NS].add(identity) }
      identity
    end

    def all_peers
      read { store[PEER_NS].to_a }
    end

    def all_blocks
      read { store[BLCK_NS].to_a }
    end

    def get_config(key)
      read { store[CONF_NS][key] }
    end

    def set_config(key, value)
      write do
        a = store.fetch(CONF_NS)
        raise "FIX SAVED DRAFTS" if value.instance_variable_get(:@db)
        a[key] = value
      end
    end

    def put_blob(data)
      raw_digest = Digest::SHA256.digest(data)
      b32_hash = Helpers.b32_encode(raw_digest)
      multihash = [BLOB_SIGIL, b32_hash, BLOB_FOOTER].join("")
      write do
        store[BLOB_NS][multihash] = data
      end

      multihash
    end

    def get_blob(blob_multihash)
      read { store[BLOB_NS][blob_multihash] }
    end

    # `nil` means "none"
    def get_message_count_for(mhash)
      raise "Expected string, got #{mhash.class}" unless mhash.is_a?(String) # Delete later
      read { store[COUNT_INDEX_NS][mhash] || 0 }
    end

    def find_all_messages(author)
      if author
        all = []
        depth = -1
        last = ""
        # TODO: This loop may become unresponsive.
        until (last == nil) || (depth > 99999)
          last = self.get_message_by_depth(author, depth += 1)
          all.push(last) if last
        end
        return all
      else
        read { store["messages"].keys }
      end
    end

    def get_message_by_depth(multihash, depth)
      raise "Expected string, got #{multihash.class}" unless multihash.is_a?(String) # Delete later
      # Map<[multihash(str), depth(int)], Signature>
      key = [multihash, depth].join(".")
      read { store[MESSAGE_BY_DEPTH_NS][key] }
    end

    def read_message(multihash)
      read { store[MESG_NS].fetch(multihash) }
    end

    def insert_message(msg)
      write do
        if store[MESG_NS].fetch(msg.multihash, false)
          return msg
        end

        if store[BLCK_NS].member?(msg.author.multihash)
          STDERR.puts("Blocked peer: #{msg.author.multihash}")
          return msg
        end

        insert_and_update_index(msg)
        msg
      end
    end

    def message_saved?(multihash)
      read { store[MESG_NS].fetch(multihash, false) }
    end

    def peer_blocked?(multihash)
      read { store[BLCK_NS].member?(multihash) }
    end

    private

    def bootstrap
      write do
        # TODO: Why is there a depth and count index??
        store[BLCK_NS] ||= Set.new
        store[BLOB_NS] ||= {}
        store[CONF_NS] ||= {}
        store[COUNT_INDEX_NS] ||= {}
        store[MESG_NS] ||= {}
        store[MESSAGE_BY_DEPTH_NS] ||= {}
        store[PEER_NS] ||= Set.new
      end
      store
    end

    def store
      @store ||= PStore.new(PIGEON_DB_PATH)
    end

    def insert_and_update_index(message)
      pub_key = message.author.multihash
      # STEP 1: Update MESG_NS, the main storage spot.
      store[MESG_NS][message.multihash] = message

      # STEP 2: Update the "message by author and depth" index
      #         this index is used to find a person's nth
      #         message
      # SECURITY AUDIT: How can we be certain the message is
      # not lying about its depth?
      key = [pub_key, message.depth].join(".")
      store[MESSAGE_BY_DEPTH_NS][key] = message.multihash
      store[COUNT_INDEX_NS][pub_key] ||= 0
      store[COUNT_INDEX_NS][pub_key] += 1
    end

    def transaction(is_read_only)
      store.transaction(is_read_only) { yield }
    end

    def write(&blk); transaction(false, &blk); end
    def read(&blk); transaction(true, &blk); end
    def on_disk?; File.file?(path); end
  end
end
