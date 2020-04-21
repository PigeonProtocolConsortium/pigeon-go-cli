module Pigeon
  class Database
    attr_reader :local_identity

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
    def find_all_messages(mhash = nil); store.find_all_messages(mhash); end
    def message_saved?(multihash); store.message_saved?(multihash); end

    def save_message(msg_obj)
      store.insert_message(Helpers.verify_message(self, msg_obj))
    end

    def read_message(multihash); store.read_message(multihash); end

    def get_message_count_for(multihash)
      store.get_message_count_for(multihash)
    end

    def get_message_by_depth(multihash, depth)
      store.get_message_by_depth(multihash, depth)
    end

    def create_message(kind, params)
      publish_draft(new_draft(kind: kind, body: params))
    end

    # Store a message that someone (not the LocalIdentity)
    # has authored.
    def ingest_message(author:,
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
      save_message(msg)
    end

    # === DRAFTS
    def reset_current_draft; set_config(CURRENT_DRAFT, nil); end

    def new_draft(kind:, body: {})
      old = get_config(CURRENT_DRAFT)
      if old
        raise "PUBLISH OR RESET CURRENT DRAFT (#{old.kind}) FIRST"
      end
      save_draft(Draft.new(kind: kind, body: body))
    end

    def save_draft(draft)
      set_config(CURRENT_DRAFT, draft)
      draft
    end

    def current_draft
      draft = store.get_config(CURRENT_DRAFT)
      if draft
        return draft
      else
        raise "THERE IS NO DRAFT. CREATE ONE FIRST."
      end
    end

    def update_draft(k, v); Helpers.update_draft(self, k, v); end

    def reset_draft
      set_config(CURRENT_DRAFT, nil)
    end

    # Author a new message.
    def publish_draft(draft = self.current_draft)
      Helpers.publish_draft(self, draft)
    end

    # === BUNDLES
    def create_bundle(file_path = DEFAULT_BUNDLE_PATH)
      # Fetch messages for all peers
      peers = all_peers + [local_identity.multihash]
      messages = peers.map do |peer|
        find_all_messages(peer)
          .map { |multihash| read_message(multihash) }
          .sort_by(&:depth)
      end.flatten

      # Render messages for all peers.
      content = messages
        .map { |message| message.render }
        .join(BUNDLE_MESSAGE_SEPARATOR)

      # MKdir
      Helpers.mkdir_p("bundle")
      # Get blobs for _all_ peers
      blobs = messages.map(&:collect_blobs).flatten.uniq
      # binding.pry if blobs.any?
      # Write bundle to dir
      # Link blobs to dir
      File.write(file_path, content + CR)
    end

    def ingest_bundle(file_path = DEFAULT_BUNDLE_PATH)
      bundle = File.read(file_path)
      tokens = Pigeon::Lexer.tokenize(bundle)
      Pigeon::Parser.parse(self, tokens)
    end

    # === BLOBS
    def get_blob(b); store.get_blob(b); end
    def put_blob(b); store.put_blob(b); end

    # === DB Management
    def get_config(k); store.get_config(k); end
    def set_config(k, v); store.set_config(k, v); end
    def reset_database; store.reset; init_ident; end

    private

    attr_reader :store

    def init_ident
      secret = get_config(SEED_CONFIG_KEY)
      if secret
        @local_identity = LocalIdentity.new(secret)
      else
        new_seed = SecureRandom.random_bytes(Ed25519::KEY_SIZE)
        set_config(SEED_CONFIG_KEY, new_seed)
        @local_identity = LocalIdentity.new(new_seed)
      end
    end
  end
end
