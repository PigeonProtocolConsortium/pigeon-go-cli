module Pigeon
  class Database
    attr_reader :local_identity

    def initialize(path: PIGEON_DB_PATH,
                   seed: SecureRandom.random_bytes(Ed25519::KEY_SIZE))
      @store = Pigeon::Storage.new(path: path)
      init_local_identity(seed)
    end

    def find_all(mhash); store.find_all(mhash); end
    def put_blob(b); store.put_blob(b); end
    def get_blob(b); store.get_blob(b); end
    def set_config(k, v); store.set_config(k, v); end
    def get_config(k); store.get_config(k); end
    def reset_current_draft; set_config(CURRENT_DRAFT, nil); end
    def reset; store.reset; end
    def add_peer(p); store.add_peer(p); end
    def block_peer(p); store.block_peer(p); end
    def remove_peer(p); store.remove_peer(p); end
    def all_peers(); store.all_peers(); end
    def all_blocks(); store.all_blocks(); end
    def message?(multihash); store.message?(multihash); end
    def save_message(msg_obj); store.save_message(msg_obj); end
    def read_message(multihash); store.read_message(multihash); end

    def get_message_count_for(multihash)
      store.get_message_count_for(multihash)
    end

    def get_message_by_depth(multihash, depth)
      store.get_message_by_depth(multihash, depth)
    end

    def create_message(kind, params)
      draft = Pigeon::Draft.new(kind: kind, db: self)
      params.map { |(k, v)| draft.put(self, k, v) }
      publish_draft(draft)
    end

    def create_bundle(file_path = DEFAULT_BUNDLE_PATH)
      content = store
        .find_all(local_identity.multihash)
        .map { |multihash| store.read_message(multihash) }
        .sort_by(&:depth)
        .map { |message| message.render }
        .join(BUNDLE_MESSAGE_SEPARATOR)
      File.write(file_path, content + CR)
    end

    def ingest_bundle(file_path = DEFAULT_BUNDLE_PATH)
      bundle = File.read(file_path)
      tokens = Pigeon::Lexer.tokenize(bundle)
      Pigeon::Parser.parse(self, tokens)
    end

    def create_draft(kind:, body: {})
      draft = Draft.new(kind: kind, body: body, db: self)
      save_draft(draft)
    end

    def save_draft(draft)
      set_config(CURRENT_DRAFT, draft)
      draft
    end

    def current_draft
      store.get_config(CURRENT_DRAFT)
    end

    def discard_draft
      set_config(CURRENT_DRAFT, nil)
    end

    # Author a new message.
    def publish_draft(draft)
      Helpers.publish_draft(self, draft)
    end

    private

    attr_reader :store

    def init_local_identity(new_seed)
      key = store.get_config(SEED_CONFIG_KEY)
      if key
        @local_identity = LocalIdentity.new(key)
      else
        @local_identity = LocalIdentity.new(new_seed)
        set_config(SEED_CONFIG_KEY, new_seed)
      end
    end
  end
end
