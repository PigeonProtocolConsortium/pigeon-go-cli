# INCOMPLETE: Ruby API Follow Along Tutorial

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

A `message` is the basic building block of a Pigeon database. As mentioned in the [protocol spec](https://tildegit.org/PigeonProtocolConsortium/protocol_spec), there are three parts to a message:

 * A header containing a `kind` field (similar to an email subject line) plus some additional meta data used by protocol clients.
 * A body containing user definable header fields.
 * A footer containing a Crockford Base32 encoded ED25119 signature to prevent forgery.

As a convenience, the Pigeon Ruby client allows developers to keep zero or one "draft" messages. A draft message is a log message that has not been signed and has not been committed to the database. Think of it as your own personal scratchpad.

A draft is not part of the protocol spec. It is a convinience provided to users of this library. You could absolutely write messages by hand, calculate their signatures, convert everything to Base32 and manually add them to the database. This would be extremely tedious, however, so the draft functionality was added for convenience.

Let's see if we have a draft to work with:

```ruby
db.get_draft
# => #<Pigeon::Draft:0x000056160b2e64a0 @author="NONE", @body={"a"=>"\"bar\"", "b"=>"&CH...QG.sha256"}, @depth=-1, @kind="unit_test", @lipmaa="NONE", @prev="NONE", @signature="NONE">
```

It appears that my database has a draft. I don't actually remember what this draft was, so I will just delete it before proceeding.

```ruby
db.delete_current_draft
# => nil
```

Now I can create a new draft. I am going to create a new `garden_diary` for a fictitious gardening app. In my gardening app, I expect every `garden_diary` message to have a `message_text` entry in its body. We can add that now, also.

```ruby
db.new_draft(kind: "garden_diary", body: {"message_text" => "Tomato plant looking healthy."})
# => #<Pigeon::Draft:0x000056160b63da68 @author="NONE", @body={"message_text"=>"\"Tomato plant looking healthy.\""}, @depth=-1, @kind="garden_diary", @lipmaa="NONE", @prev="NONE", @signature="NONE">
```

A couple notes here:

 * `"garden_diary` is the message `kind`. This is definable by application developers and helps determine the type of message we are dealing with. A fictitious diary app might have other entries such as `"status_update"` or `"photo_entry"`. It really just depends on the application you are building.
 * Notice that my hash used string keys for the `"message_text"` body entry. You can only use strings for key / value pairs (no symbols or numbers). Later on we will learn how to attach files to messages.
 * The `body:` part is optional. I could have called `db.new_draft(kind: "garden_diary")` and added key / value pairs to the body later.

Oops! Speaking of adding entries to a draft's body, it looks like I forgot something. In my fictitious gardening app, a `garden_diary` entry doesn't just have a `"message_text"`, it also has a `"current_mood"` entry. Luckily, it is easy to add keys to unpublished drafts. Let's add the key now:

```ruby
db.update_draft("current_mood", "Feeling great")
# => "\"Feeling great\""
```

OK, I think our draft message is looking better. Let's take a look:

```ruby
db.get_draft
# => => #<Pigeon::Draft:0x000056160b3e6be8 @author="NONE", @body={"message_text"=>"\"Tomato plant looking healthy.\"", "current_mood"=>"\"Feeling great\""}, @depth=-1, @kind="garden_diary", @lipmaa="NONE", @prev="NONE", @signature="NONE">
```

I can see the status of my current draft message using `db.get_draft`. It's not very human readable though. To get a more human readable version, I can use the `render_as_draft` method on a `Draft` object:

```ruby
human_readable_string = db.get_draft.render_as_draft
# => "author DRAFT\nkind garden_dia...."
puts human_readable_string
# =>  author DRAFT
#     kind garden_diary
#     prev DRAFT
#     depth DRAFT
#     lipmaa DRAFT
#
#     message_text:"Tomato plant looking healthy."
#     current_mood:"Feeling great"
```

Some interesting things about the message we just rendered:

 * Unlike a message, a draft has no signature (yet).
 * The `author`, `kind`, `prev`, `depth`, `lipmaa` properties are all set to `"DRAFT"`. Real values will be populated when we finally publish the draft.

## Turning Drafts Into Messages

Now that I am happy with my draft, I can publish it. Once published, my message cannot be modified, so it is very important to visually inspect a draft with `db.get_draft` before proceeding.
Since we did that in the last step, I will go ahead and publish the message:

```
my_message = db.publish_draft
# => #<Pigeon::Message:0x000056160b50dd00
#  @author=#<Pigeon::RemoteIdentity:0x000056160b50dd78 @multihash="@753FT97S1FD3SRYPTVPQQ64F7HCEAZMWVBKG0C2MYMS5MJ3SBT6G.ed25519">,
#  @body={"message_text"=>"\"Tomato plant looking healthy.\"", "current_mood"=>"\"Feeling great\""},
#  @depth=0,
#  @kind="garden_diary",
#  @lipmaa=0,
#  @prev="NONE",
#  @signature="2ZHC8TX3P2SQVQTMFYXTAT4S02RN43JNZNECRJDA7QMSJNE5G7NV7GTRK3PGFHFY9MBE1Q95BCKBSJH4V0PTX6945A34Z1CARTGH230.sig.ed25519">
```

Let's look at our new message in a human-readable way:

```ruby
puts my_message.render
# =>  author @753...T6G.ed25519
#     kind garden_diary
#     prev NONE
#     depth 0
#     lipmaa 0
#
#     message_text:"Tomato plant looking healthy."
#     current_mood:"Feeling great"
#
#     signature 2ZH...230.sig.ed25519
```

We see that unlike our draft, the message has a signature. The header fields are also populated.

In the next section, we will learn more about messages.

## Working With Messages

Drafts can be helpful when you are building a message incrementally and need a place to temporarily store things between application restarts.
What about when you have all the information you need and want to publish immediately?

In those cases, you can call `db.add_message` and your message will be published to your database immediately. No intermediate steps:

```ruby
message = db.add_message("garden_entry", {"message_text" => "The basil is just OK", "current_mood" => "content"})
# => #<Pigeon::Message:0x000056160b5cb558
#  @author=#<Pigeon::RemoteIdentity:0x000056160b5cb5a8 @multihash="@753...T6G.ed25519">,
#  @body={"message_text"=>"\"The basil is just OK\"", "current_mood"=>"\"content\""},
#  @depth=1,
#  @kind="garden_entry",
#  @lipmaa=0,
#  @prev="%EM7...260.sha256",
#  @signature="J59...238.sig.ed25519">

puts message.render
# =>  author @753...T6G.ed25519
#     kind garden_entry
#     prev %EM7...260.sha256
#     depth 1
#     lipmaa 0
#
#     message_text:"The basil is just OK"
#     current_mood:"content"
#
#     signature J59...238.sig.ed25519
```

We should now have 2 messages in the local database.
Let's take a look using the `db.all_messages` method:

```ruby
db.all_messages
# => ["%EM749647YHD3CBEC19TJJ7YME7BDXJ2KZ38ZZKS6E3VA0JHAM260.sha256", "%0HTM1H6ETBMKCPP5JMN2XEM060RYQHJ8P5KY09WRPTTVZ20N3EFG.sha256"]
```

The `#all_messages` method returns an array containing every message multihash in the database. We can then pass the multihash to the `db.read_message` method to retrieve the corresponding `Pigeon::Message` object.

Let's look at the old log message we created from a draft previously:

```ruby
old_message = db.read_message("%EM749647YHD3CBEC19TJJ7YME7BDXJ2KZ38ZZKS6E3VA0JHAM260.sha256")
# => #<Pigeon::Message:0x000056160b35f580
#  @author=#<Pigeon::RemoteIdentity:0x000056160b35ee50 @multihash="@753FT97S1FD3SRYPTVPQQ64F7HCEAZMWVBKG0C2MYMS5MJ3SBT6G.ed25519">,
#  @body={"message_text"=>"\"Tomato plant looking healthy.\"", "current_mood"=>"\"Feeling great\""},
#  @depth=0,
#  @kind="garden_diary",
#  @lipmaa=0,
#  @prev="NONE",
#  @signature="2ZHC8TX3P2SQVQTMFYXTAT4S02RN43JNZNECRJDA7QMSJNE5G7NV7GTRK3PGFHFY9MBE1Q95BCKBSJH4V0PTX6945A34Z1CARTGH230.sig.ed25519">

puts old_message.render
# author @753FT97S1FD3SRYPTVPQQ64F7HCEAZMWVBKG0C2MYMS5MJ3SBT6G.ed25519
# kind garden_diary
# prev NONE
# depth 0
# lipmaa 0
#
# message_text:"Tomato plant looking healthy."
# current_mood:"Feeling great"
#
# signature 2ZHC8TX3P2SQVQTMFYXTAT4S02RN43JNZNECRJDA7QMSJNE5G7NV7GTRK3PGFHFY9MBE1Q95BCKBSJH4V0PTX6945A34Z1CARTGH230.sig.ed25519
```

Additionally, there is a `have_message?` helper that let's us know if we have a message in the local DB. It will return a `Pigeon::Message` (if found) or `false`:

```
db.have_message?("%AAAM1H6ETBBBCPP5JMN2XEM060RYQCCCP5KY09WRPTTVZ20N3FFF.sha256")
# => false
```

## Working with Peers

Building a gardening diary is not very fun unless there is a way of sharing your work. Pigeon supports data transfer through the use of peers.

Every Pigeon database (including ours) has a unique identifier to identify itself.

Let's call `db.who_am_i` to find out what our database multihash is:

```ruby
me = db.who_am_i
# => #<Pigeon::LocalIdentity:0x000056160b5ca658
#  @multihash="@753FT97S1FD3SRYPTVPQQ64F7HCEAZMWVBKG0C2MYMS5MJ3SBT6G.ed25519",
#  @seed="REDACTED",
#  @signing_key=#<Ed25519::SigningKey:REDACTED>>
```

Calling `db.who_am_i` returned a `Pigeon::LocalIdentity`. To get results in a more copy/pastable format, call `#multihash` on the `LocalIdentity`:

```ruby
me.multihash
# => "@753FT97S1FD3SRYPTVPQQ64F7HCEAZMWVBKG0C2MYMS5MJ3SBT6G.ed25519"
```

You can send this string to all your friends so they can add you as a peer to their respective databases.
Let's add a friend to our database now.
My friend has informed me her Pigeon identity is `"@753FT97S1FD3SRYPTVPQQ64F7HCEAZMWVBKG0C2MYMS5MJ3SBT6G.ed25519"`:

```ruby
db.add_peer("@753FT97S1FD3SRYPTVPQQ64F7HCEAZMWVBKG0C2MYMS5MJ3SBT6G.ed25519")
# => "@753FT97S1FD3SRYPTVPQQ64F7HCEAZMWVBKG0C2MYMS5MJ3SBT6G.ed25519"
```

My client will now keep a local copy of my friend's DB on disk at all times. Since Pigeon is an offline-only protocol, she will need to mail me an SD Card with her files. We will cover this later in the "Bundles" section.

If you ever lose track of who your peers are, you can call `db.all_peers` to get a list:

```ruby
db.all_peers
# => ["@753FT97S1FD3SRYPTVPQQ64F7HCEAZMWVBKG0C2MYMS5MJ3SBT6G.ed25519"]
```

You can also remove peers if you no longer need to replicate their messages:

```ruby
db.remove_peer("@753FT97S1FD3SRYPTVPQQ64F7HCEAZMWVBKG0C2MYMS5MJ3SBT6G.ed25519")
# => "@753FT97S1FD3SRYPTVPQQ64F7HCEAZMWVBKG0C2MYMS5MJ3SBT6G.ed25519"
db.all_peers
# => []
```

It is also possible to block peers as needed via `db.block_peer`. `block_peer` is _not_ the same as `remove_peer`. Blocking a peer will prevent gossip from flowing through your database. All of their messages will be ignored and none of your peers will be able to retrieve their messages through you via gossip:

```ruby
db.block_peer("@753FT97S1FD3SRYPTVPQQ64F7HCEAZMWVBKG0C2MYMS5MJ3SBT6G.ed25519")
# => "@753FT97S1FD3SRYPTVPQQ64F7HCEAZMWVBKG0C2MYMS5MJ3SBT6G.ed25519"

db.all_blocks
# => ["@753FT97S1FD3SRYPTVPQQ64F7HCEAZMWVBKG0C2MYMS5MJ3SBT6G.ed25519"]

db.peer_blocked?("@753FT97S1FD3SRYPTVPQQ64F7HCEAZMWVBKG0C2MYMS5MJ3SBT6G.ed25519")
# => true
```

## Querying the Database

I stopped here. The remainder of the file is incomplete and will be completed later.

```
db.get_message_by_depth
db.get_message_count_for
```

## Attaching Files to Messages

```
db.add_blob(binary_string)
db.get_blob(multihash)
```

## File Based Communication via Bundles

```
db.export_bundle
db.import_bundle
```

