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

## Installation

Installation steps change over time. Please see [README.md](README.md) for the most up-to-date information.

## Creating a Database Object

When building Pigeon-based applications, a `Pigeon::Database` object controls nearly all interactions with the database.
For the rest of the tutorial we will use the variable name `db` to refer to the current database.

You can create your own database with the following steps:

```ruby
require_relative "pigeon"
db = Pigeon::Database.new(path: "pigeon.db")
# => #<Pigeon::Database:0x000055a1ecca45e8>
```

An optional `path:` argument can be passed to `Pigeon::Database.new`. This arg will default to `pigeon.db` within the local directory if not provided. We recommend this default as it will allow you to use the [command line interface](cli_tutorial.md) more effectively.

If at any point you wish to start the tutorial over, you can reset your local database with the following command:

```ruby
db.reset_database
```

One note about the `pigeon.db` file before moving to the next section: Do not share the `pigeon.db` file with anyone. Doing so will compromise the tamper-resistant properties of Pigeon and allow bad actors to forge messages in your name. Use `bundles` to safely share data with remote peers (covered later).

## Working with Drafts

```
  ###   #####   ###   ####   ####   #####  ####          #   #  #####  ####   #####
 #   #    #    #   #  #   #  #   #  #       #  #         #   #  #      #   #  #
 #        #    #   #  #   #  #   #  #       #  #         #   #  #      #   #  #
  ###     #    #   #  ####   ####   ####    #  #         #####  ####   ####   ####
     #    #    #   #  #      #      #       #  #         #   #  #      # #    #
 #   #    #    #   #  #      #      #       #  #         #   #  #      #  #   #
  ###     #     ###   #      #      #####  ####          #   #  #####  #   #  #####
```
A `message` is the basic building block of a Pigeon database.

Since messages are often built
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
 * Blobs are stored

## File Based Communication via Bundles
export_bundle
import_bundle


