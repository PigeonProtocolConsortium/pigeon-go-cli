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
      write { store[PEER_NS].add(identity) }
      identity
    end

    def remove_peer(identity)
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

    def _get_config(key)
      read { store[CONF_NS][key] }
    end

    def _add_config(key, value)
      write do
        a = store.fetch(CONF_NS)
        raise "FIX SAVED DRAFTS" if value.instance_variable_get(:@db)

        a[key] = value
      end
    end

    def add_blob(data)
      size = data.bytesize
      if size > BLOB_BYTE_LIMIT
        raise "Blob size limit is #{BLOB_BYTE_LIMIT} bytes. Got #{size}"
      end

      raw_digest = Digest::SHA256.digest(data)
      b32_hash = Helpers.b32_encode(raw_digest)
      multihash = [BLOB_SIGIL, b32_hash, BLOB_FOOTER].join("")
      write_to_disk(multihash, data)
      multihash
    end

    def get_blob(blob_multihash)
      path = File.join(Helpers.hash2file_path(blob_multihash))
      path = File.join(PIGEON_BLOB_PATH, path)
      File.read(path) if File.file?(path)
    end

    # `nil` means "none"
    def get_message_count_for(mhash)
      unless mhash.is_a?(String)
        raise "Expected string, got #{mhash.class}"
      end # Delete later

      read { store[COUNT_INDEX_NS][mhash] || 0 }
    end

    def all_messages(author)
      if author
        all = []
        depth = -1
        last = ""
        # TODO: This loop may become unresponsive.
        until last.nil? || (depth > 99_999)
          last = get_message_by_depth(author, depth += 1)
          all.push(last) if last
        end
        all
      else
        read { store["messages"].keys }
      end
    end

    def get_message_by_depth(multihash, depth)
      unless multihash.is_a?(String)
        raise "Expected string, got #{multihash.class}"
      end # Delete later

      # Map<[multihash(str), depth(int)], Signature>
      key = [multihash, depth].join(".")
      read { store[MESSAGE_BY_DEPTH_NS][key] }
    end

    def read_message(multihash)
      read { store[MESG_NS].fetch(multihash) }
    end

    def insert_message(msg)
      write do
        return msg if store[MESG_NS].fetch(msg.multihash, false)

        if store[BLCK_NS].member?(msg.author.multihash)
          warn("Blocked peer: #{msg.author.multihash}")
          return msg
        end

        insert_and_update_index(msg)
        msg
      end
    end

    def have_message?(multihash)
      read { store[MESG_NS].fetch(multihash, false) }
    end

    def peer_blocked?(multihash)
      read { store[BLCK_NS].member?(multihash) }
    end

    def have_blob?(multihash)
      path = File.join(PIGEON_BLOB_PATH, Helpers.hash2file_path(multihash))
      File.file?(path)
    end

    private

    def write_to_disk(mhash, data)
      Helpers.write_to_disk(PIGEON_BLOB_PATH, mhash, data)
    end

    def bootstrap
      write do
        store[BLCK_NS] ||= Set.new
        store[CONF_NS] ||= {}
        store[COUNT_INDEX_NS] ||= {}
        store[MESG_NS] ||= {}
        store[MESSAGE_BY_DEPTH_NS] ||= {}
        store[PEER_NS] ||= Set.new
      end
      Helpers.mkdir_p(PIGEON_BLOB_PATH)
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

    def write(&blk)
      transaction(false, &blk)
    end

    def read(&blk)
      transaction(true, &blk)
    end

    def on_disk?
      File.file?(path)
    end
  end
end
