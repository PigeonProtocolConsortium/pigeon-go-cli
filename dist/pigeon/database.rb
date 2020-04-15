module Pigeon
  class Database
    def initialize
    end

    def create_bundle(file_path = DEFAULT_BUNDLE_PATH)
      s = Pigeon::Storage.current
      content = s
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
  end
end
