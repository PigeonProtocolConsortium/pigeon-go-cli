require "pigeon"
require "pry"

db = Pigeon::Database.new(path: "my.db")

db.reset_draft
db.current_draft
db.reset_draft
db.publish_draft
db.save_draft
db.save_message
db.reset_current_draft
db.message_saved?
db.read_message
db.create_message
db.find_all_messages
db.get_message_by_depth
db.get_message_count_for
db.local_identity
db.remove_peer
db.add_peer
db.block_peer
db.all_peers
db.all_blocks
db.get_blob
db.put_blob
db.create_bundle
db.get_config
db.ingest_bundle
db.set_config
db.reset_database
