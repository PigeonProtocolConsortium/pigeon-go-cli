module Pigeon
  class Bundle
    def self.create(file_path = DEFAULT_BUNDLE_PATH)
      s = Pigeon::Storage.current
      last = s.message_count
      author = Pigeon::LocalIdentity.current
      range = (0...last).to_a
      content = range
        .map { |depth| s.get_message_by_depth(author.public_key, depth) }
        .map { |multihash| s.find_message(multihash) }
        .map { |message| message.render }
        .join(BUNDLE_MESSAGE_SEPARATOR)
      File.write(file_path, content + CR)
    end

    def self.ingest(file_path)
      bundle = File.read(file_path)
      tokens = Pigeon::Lexer.tokenize(bundle)
      Pigeon::Parser.parse(tokens).map(&:save!)
    end
  end
end
