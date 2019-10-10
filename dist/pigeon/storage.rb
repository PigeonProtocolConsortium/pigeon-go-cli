module Pigeon
  class Storage
    ROOT_DIR = ".pigeon"
    CONF_DIR = "conf"
    BLOB_DIR = "blobs"
    PEER_DIR = "peers"
    USER_DIR = "user"
    BLOCK_DIR = "blocked"

    BLOB_HEADER = "&"
    BLOB_FOOTER = ".sha256"

    def self.current
      @current ||= self.new
    end

    def initialize
      unless initialized?
        create_root_dir
        create_conf_dir
        create_blob_dir
        create_peer_dir
        create_user_dir
      end
    end

    def set_conf(key, value)
      path = conf_path_for(key)
      maybe_touch(path)
      File.write(path, value.to_s)
    end

    def get_conf(key)
      File.read(conf_path_for(key))
    end

    def set_blob(data)
      hex_digest = Digest::SHA256.hexdigest(data)
      path = blob_path_for(hex_digest)
      File.write(path, data)

      [BLOB_HEADER, hex_digest, BLOB_FOOTER].join("")
    end

    def get_blob(hex_digest)
      hd = hex_digest.gsub(BLOB_HEADER, "").gsub(BLOB_FOOTER, "")
      # Allows user to pass first n chars of a
      # hash instead of the whole hash.
      f = Dir[blob_path_for(hd) + "*"].first

      File.file?(f) ? File.read(f) : nil
    end

    def add_peer(identity)
      path = KeyPair.strip_headers(identity)
      FileUtils.mkdir_p(File.join(peer_dir, path))
      identity
    end

    def remove_peer(identity)
      path = KeyPair.strip_headers(identity)
      FileUtils.rm_rf(File.join(peer_dir, path))
      identity
    end

    def block_peer(identity)
      remove_peer(identity)
      path = KeyPair.strip_headers(identity)
      FileUtils.touch(File.join(block_dir, path))
      identity
    end

    def all_peers
      Dir[File.join(peer_dir, "*")]
        .map { |x| File.split(x).last }
        .map { |x| KeyPair.add_headers(x) }
    end

    def all_blocks
      Dir[File.join(block_dir, "*")]
        .map { |x| File.split(x).last }
        .map { |x| KeyPair.add_headers(x) }
    end

    private

    def initialized?
      File.directory?(root_dir)
    end

    def root_dir
      @root_dir ||= File.join(ROOT_DIR)
    end

    def blob_dir
      @blob_dir ||= File.join(ROOT_DIR, BLOB_DIR, "sha256")
    end

    def peer_dir
      @peer_dir ||= File.join(ROOT_DIR, PEER_DIR)
    end

    def block_dir
      File.join(ROOT_DIR, BLOCK_DIR)
    end

    def user_dir
      File.join(ROOT_DIR, USER_DIR)
    end

    def blob_path_for(hex_hash_string)
      first_part = File.join(blob_dir, hex_hash_string[0, 2])
      FileUtils.mkdir_p(first_part)
      File.join(first_part, hex_hash_string[2..-1])
    end

    def maybe_touch(path)
      FileUtils.touch(path) unless File.file?(path)
    end

    def conf_path_for(key)
      File.join(conf_dir, key.to_s)
    end

    def conf_dir
      @conf_dir ||= File.join(ROOT_DIR, CONF_DIR)
    end

    def create_conf_dir
      FileUtils.mkdir_p(conf_dir)
    end

    def create_blob_dir
      FileUtils.mkdir_p(blob_dir)
    end

    def create_root_dir
      FileUtils.mkdir_p(root_dir)
    end

    def create_peer_dir
      FileUtils.mkdir_p(peer_dir)
      FileUtils.mkdir_p(block_dir)
    end

    def create_user_dir
      FileUtils.mkdir_p(user_dir)
    end
  end
end
