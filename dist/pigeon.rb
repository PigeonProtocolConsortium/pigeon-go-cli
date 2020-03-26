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
  DEFAULT_BUNDLE_PATH = "./pigeon.bundle"

  # MESSAGE TEMPLATE CONSTANTS:
  HEADER_TPL = File.read(File.join(TPL_DIR, "1_header.erb")).sub("\n", "")
  BODY_TPL = File.read(File.join(TPL_DIR, "2_body.erb")).sub("\n", "")
  FOOTER_TPL = File.read(File.join(TPL_DIR, "3_footer.erb")).sub("\n", "")
  COMPLETE_TPL = [HEADER_TPL, BODY_TPL, FOOTER_TPL].join("")
  CURRENT_DRAFT = "HEAD.draft"
  EMPTY_MESSAGE = "NONE"
  OUTBOX_PATH = File.join(".pigeon", "user")
  DRAFT_PLACEHOLDER = "DRAFT"
  CR = "\n"
  BUNDLE_MESSAGE_SEPARATOR = CR * 2
  # /MESSAGE TEMPLATE CONSTANTS

  # Internal namespaces for PStore keys:
  ROOT_NS = ".pigeon"
  CONF_NS = "conf"
  BLOB_NS = "blobs"
  PEER_NS = "peers"
  USER_NS = "user"
  BLCK_NS = "blocked"
  MESG_NS = "messages"
  DEPTH_INDEX_NS = "messages.by_depth"

  # ^ Internal namespaces for PStore keys

  BLOB_SIGIL = "&"
  MESSAGE_SIGIL = "%"
  IDENTITY_SIGIL = "@"
  STRING_SIGIL = "\""
  BLOB_FOOTER = ".sha256"
  SIG_FOOTER = ".sig.ed25519"

  # Error messages
  PREV_REQUIRES_SAVE = "Can't fetch `prev` on unsaved messages"
  NO_DRAFT_FOUND = "NO DRAFT FOUND"
  STRING_KEYS_ONLY = "String keys only"
  MISSING_BODY = "BODY CANT BE EMPTY"
end

require_relative File.join("pigeon", "local_identity.rb")
require_relative File.join("pigeon", "remote_identity.rb")
require_relative File.join("pigeon", "storage.rb")
require_relative File.join("pigeon", "draft_serializer.rb")
require_relative File.join("pigeon", "message_serializer.rb")
require_relative File.join("pigeon", "message.rb")
require_relative File.join("pigeon", "draft.rb")
require_relative File.join("pigeon", "lexer.rb")
require_relative File.join("pigeon", "parser.rb")
require_relative File.join("pigeon", "bundle.rb")
