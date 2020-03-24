module Pigeon
  class Bundle
    def self.create(file_path = DEFAULT_BUNDLE_PATH)
      s = Pigeon::Storage.current
      last = s.message_count
      author = Pigeon::LocalIdentity.current
      range = (0...last).to_a
      content = range
        .map { |depth| s.get_message_by_depth(author, depth) }
        .map { |multihash| s.find_message(multihash) }
        .map { |message| message.render }
        .join(BUNDLE_MESSAGE_SEPARATOR)
      File.write(file_path, content + CR)
    end

    def self.ingest(file_path)
    end

    private

    def initialize
    end
  end
end
