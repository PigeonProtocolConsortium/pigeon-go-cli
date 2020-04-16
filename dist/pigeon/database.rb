module Pigeon
  class Database
    attr_reader :local_identity

    def initialize(path: PIGEON_DB_PATH,
                   seed: SecureRandom.random_bytes(Ed25519::KEY_SIZE))
      @store = Pigeon::Storage.new(path: path)
      init_local_identity(seed)
    end

    def find_all; store.find_all; end
    def put_blob(b); store.put_blob(b); end
    def set_config(k, v); store.set_config(k, v); end
    def get_config(k); store.get_config(k); end
    def reset_current_draft; set_config(CURRENT_DRAFT, nil); end
    def reset; store.reset; end

    def create_message(kind, params)
      draft = Pigeon::Draft.new(kind: kind, db: self)
      params.map { |(k, v)| draft[k] = v }
      draft.publish
    end

    def create_bundle(file_path = DEFAULT_BUNDLE_PATH)
      content = store
        .find_all(Pigeon::LocalIdentity.current.multihash)
        .map { |multihash| s.read_message(multihash) }
        .sort_by(&:depth)
        .map { |message| message.render }
        .join(BUNDLE_MESSAGE_SEPARATOR)
      File.write(file_path, content + CR)
    end

    def ingest_bundle(file_path = DEFAULT_BUNDLE_PATH)
      bundle = File.read(file_path)
      tokens = Pigeon::Lexer.tokenize(bundle)
      Pigeon::Parser.parse(tokens)
    end

    def create_draft(kind:, body: {})
      save_draft(Draft.new(kind: kind, body: body))
    end

    def save_draft(draft)
      set_config(CURRENT_DRAFT, draft)
      draft
    end

    def current_draft
      store.get_config(CURRENT_DRAFT) or raise NO_DRAFT_FOUND
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
