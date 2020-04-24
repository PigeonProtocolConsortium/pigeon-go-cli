module Pigeon
  class Database
    attr_reader :who_am_i

    def initialize(path: PIGEON_DB_PATH)
      @store = Pigeon::Storage.new(path: path)
      init_ident
    end

    # === PEERS
    def add_peer(p); store.add_peer(p); end
    def block_peer(p); store.block_peer(p); end
    def remove_peer(p); store.remove_peer(p); end
    def peer_blocked?(p); store.peer_blocked?(p); end
    def all_blocks(); store.all_blocks(); end
    def all_peers(); store.all_peers(); end

    # === MESSAGES
    def all_messages(mhash = nil); store.all_messages(mhash); end
    def message_saved?(multihash); store.message_saved?(multihash); end

    def _save_message(msg_obj)
      store.insert_message(Helpers.verify_message(self, msg_obj))
    end

    def read_message(multihash); store.read_message(multihash); end

    def get_message_count_for(multihash)
      store.get_message_count_for(multihash)
    end

    def get_message_by_depth(multihash, depth)
      store.get_message_by_depth(multihash, depth)
    end

    def add_message(kind, params)
      publish_draft(new_draft(kind: kind, body: params))
    end

    # Store a message that someone (not the LocalIdentity)
    # has authored.
    def _ingest_message(author:,
                        body:,
                        depth:,
                        kind:,
                        lipmaa:,
                        prev:,
                        signature:)
      msg = Message.new(author: RemoteIdentity.new(author),
                        kind: kind,
                        body: body,
                        prev: prev,
                        lipmaa: lipmaa,
                        signature: signature,
                        depth: depth)
      _save_message(msg)
    end

    # === DRAFTS
    def reset_draft; add_config(CURRENT_DRAFT, nil); end

    def new_draft(kind:, body: {})
      old = get_config(CURRENT_DRAFT)
      if old
        raise "PUBLISH OR RESET CURRENT DRAFT (#{old.kind}) FIRST"
      end
      save_draft(Draft.new(kind: kind, body: body))
    end

    def save_draft(draft)
      add_config(CURRENT_DRAFT, draft)
      draft
    end

    def get_draft
      draft = store.get_config(CURRENT_DRAFT)
      if draft
        return draft
      else
        raise "THERE IS NO DRAFT. CREATE ONE FIRST."
      end
    end

    def update_draft(k, v); Helpers.update_draft(self, k, v); end

    def reset_draft
      add_config(CURRENT_DRAFT, nil)
    end

    # Author a new message.
    def publish_draft(draft = self.get_draft)
      Helpers.publish_draft(self, draft)
    end

    # === BUNDLES
    def export_bundle(file_path = DEFAULT_BUNDLE_PATH)
      # Fetch messages for all peers
      peers = all_peers + [who_am_i.multihash]
      messages = peers.map do |peer|
        all_messages(peer)
          .map { |multihash| read_message(multihash) }
          .sort_by(&:depth)
      end.flatten

      # Attach blobs for all messages in bundle.
      messages
        .map(&:collect_blobs)
        .flatten
        .uniq
        .map { |mhash| ["bundle", mhash, get_blob(mhash)] }
        .map { |arg| Helpers.write_to_disk(*arg) }

      # Render messages for all peers.
      content = messages
        .map { |message| message.render }
        .join(BUNDLE_MESSAGE_SEPARATOR)
      File.join(file_path, "gossip.pgn")
      File.write(File.join(file_path, "gossip.pgn"), content + CR)
    end

    def import_bundle(file_path = DEFAULT_BUNDLE_PATH)
      bundle = File.read(File.join(file_path, "gossip.pgn"))
      tokens = Pigeon::Lexer.tokenize(bundle)
      Pigeon::Parser.parse(self, tokens)
    end

    # === BLOBS
    def get_blob(b); store.get_blob(b); end
    def add_blob(b); store.add_blob(b); end

    # === DB Management
    def get_config(k); store.get_config(k); end
    def add_config(k, v); store.add_config(k, v); end
    def reset_database; store.reset; init_ident; end

    private

    attr_reader :store

    def init_ident
      secret = get_config(SEED_CONFIG_KEY)
      if secret
        @who_am_i = LocalIdentity.new(secret)
      else
        new_seed = SecureRandom.random_bytes(Ed25519::KEY_SIZE)
        add_config(SEED_CONFIG_KEY, new_seed)
        @who_am_i = LocalIdentity.new(new_seed)
      end
    end
  end
end
