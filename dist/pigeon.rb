require "base64"
require "digest"
require "ed25519"
require "securerandom"

# Remove this when we launch or add ENVs:
require "pry"

module Pigeon
  HEADER, FOOTER = ["@", ".ed25519"]
  SEED_CONFIG_KEY = "SEED"
  VERSION = "0.0.1"
  TPL_DIR = "views"

  PIGEON_DB_PATH = File.join("db.pigeon")
  # MESSAGE TEMPLATE CONSTANTS:
  HEADER_TPL = File.read(File.join(TPL_DIR, "1_header.erb")).sub("\n", "")
  BODY_TPL = File.read(File.join(TPL_DIR, "2_body.erb")).sub("\n", "")
  FOOTER_TPL = File.read(File.join(TPL_DIR, "3_footer.erb")).sub("\n", "")
  COMPLETE_TPL = [HEADER_TPL, BODY_TPL, FOOTER_TPL].join("")
  # /MESSAGE TEMPLATE CONSTANTS

  # Internal namespaces for PStore keys:
  ROOT_NS = ".pigeon"
  CONF_NS = "conf"
  BLOB_NS = "blobs"
  PEER_NS = "peers"
  USER_NS = "user"
  BLCK_NS = "blocked"
  # ^ Internal namespaces for PStore keys

  BLOB_SIGIL = "&"
  SIGNATURE_SIGIL = "%"
  IDENTITY_SIGIL = "@"
  STRING_SIGIL = "\""
  BLOB_FOOTER = ".sha256"
end

require_relative File.join("pigeon", "key_pair.rb")
require_relative File.join("pigeon", "storage.rb")
require_relative File.join("pigeon", "template.rb")
require_relative File.join("pigeon", "message.rb")
