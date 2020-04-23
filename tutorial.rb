# add_blob
# add_config
# add_message
# add_peer
# all_blocks
# all_messages
# all_peers
# block_peer
# get_blob
# get_config
# get_draft
# get_message_by_depth
# get_message_count_for
# message_saved?
# peer_blocked?
# who_am_i
# new_draft
# publish_bundle
# publish_draft
# read_message
# remove_peer
# reset_database
# reset_draft
# save_bundle
# save_draft
# update_draft

require_relative "lib/pigeon"
require "pry"
files = %w(a.gif b.gif c.gif)
body = { "what" => "A simple bundle with a few blobs" }
db = Pigeon::Database.new(path: "new.db")
db.add_message("description", body)
files.map { |file| db.add_blob(file) }
binding.pry
db.save_bundle("./spec/fixtures/has_blobs")
