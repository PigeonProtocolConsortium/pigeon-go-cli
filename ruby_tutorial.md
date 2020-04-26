# Ruby API Follow Along Tutorial

## Introduction and Intended Audience

Pigeon is a peer-to-peer log database that serves the needs of off grid and delay-tolerant systems.
Pigeon Ruby is a Ruby-based database client that is interoperable with other compliant Pigeon Protocol clients.
It allows users to manage replicated, distributed log databases. Pigeon makes this possible even on systems with no internet access via sneakernet, thanks to a bundle file specification and extreme delay tolerance properties.

This document will teach you how to:

 * Create and manage a database.
 * Build messages using drafts.
 * Manage and query existing messages.
 * Replicate a database among peers.
 * Go beyond simple text messages and attach files to messages.
 * Communicate with remote databases using bundle files.

This guide assumes you are familiar with Ruby and the Pigeon Protocol. For an introduction to the protocol, see our protocol specification [here](https://tildegit.org/PigeonProtocolConsortium/protocol_spec).

## Creating a Database Object

```ruby
require_relative "pigeon"
db = Pigeon::Database.new(path: "pigeon.db")
# => #<Pigeon::Database:0x000055a1ecca45e8>
```
reset_database
add_config
get_config
 - Don't share this file (use bundles instead!)
 - Where do blobs live?

## Working with Drafts
new_draft
delete_current_draft
update_draft
get_draft
publish_draft

## Turning Drafts Into Messages

## Working With Messages
add_message
all_messages
read_message
have_message?

## Working with Peers
who_am_i
add_peer
all_peers
remove_peer
block_peer
all_blocks
peer_blocked?

## Querying the Database
get_message_by_depth
get_message_count_for

## Attaching Files to Messages
add_blob
get_blob

## File Based Communication via Bundles
export_bundle
import_bundle


