![](logo.png)

# Pigeon Ruby

This is a WIP [Pigeon Protocol] client written in Ruby.

# Installation

We are not yet on Rubygems. The gem will be released after we are fully compliant with the spec and have high test coverage stats.

In the meantime:

```
git clone https://tildegit.org/PigeonProtocolConsortium/pigeon_ruby.git
cd pigeon_ruby
gem build pigeon.gemspec
gem install pigeon-0.0.5.gem
pigeon-cli identity new # Should work. Raise issue if not.
pigeon-cli status
pigeon-cli help
```

# Usage: CLI

See `pigeon-cli help` for documentation.
See `kitchen_sink.sh` examples.

# Usage: Ruby Lib

TODO

# Current Status

 - [X] pigeon identity new
 - [X] pigeon identity show
 - [X] pigeon status
 - [X] pigeon blob set
 - [X] pigeon blob get
 - [X] pigeon peer add
 - [X] pigeon peer remove
 - [X] pigeon peer block
 - [X] pigeon peer all
 - [X] 100% coverage
 - [X] Convert `".sig.ed25519"` literals to constants
 - [X] Rename numerous "pigeon message ..." commands to "pigeon draft ..."
 - [X] pigeon draft create
 - [X] pigeon draft append
 - [X] pigeon draft current
 - [X] pigeon draft save
 - [X] pigeon bundle create
 - [X] Use JSON.stringify() for string keys (instead of `inspect`)
 - [X] Move literals into `Pigeon` module as constants, again.
 - [X] pigeon message find
 - [X] pigeon message find-all for local feed.
 - [X] pigeon bundle consume (We are minimally feature complete at this point)
 - [X] Fix the diagram in the spec document
 - [X] Validate inputs for `Draft#[]=`.
 - [X] Put all the [HEADER, string, FOOTER].join("") nonsense into Pigeon::Helpers
 - [X] Use raw SHA256 hashes for blob multihashes, not hex.
 - [X] Change all the `{40,90}` values in ::Lexer to real length values
 - [X] Don't double-ingest messages. It will screw up indexes.
 - [X] 100% test coverage
 - [X] Implement pigeon message find-all for peer feed. I will need to add index for `author => message_count`
 - [X] Switch to Crockford base32- Simplifies support for legacy systems. Easy to implement.
 - [X] Fix `scratchpad.sh` to use Base32
 - [X] Rename (RemoteIdentity|LocalIdentity)#public_key to #multihash for consistency with other types.
 - [X] Fix diagram in spec doc
 - [X] refactor `Bundle.create` to use `message find-all`.
 - [X] Rename `message find` to `message read`, since other finders return a multihash.
 - [X] Message.ingest should be the only code path to message authoring.
 - [X] Don't allow any type of whitespace in `kind` or `string` keys. Write a test for this.
 - [X] Run Flog / Flay and friends to find duplications. Will aid in port to other languages.
 - [X] Make all methods private except those required for the CLI.
 - [X] Add Lipmaa links like the Bamboo folks do.
 - [X] Set a max message size.
 - [X] Clean up all singletons / .current hacks
 - [X] Reduce cross cutting where collaborating objects need access to `@db`
 - [X] Ensure all disks writes perform verification!
 - [X] Make CLI names consistent with API names. Eg: find vs. read.
 - [X] `find-all` should....find all. Currently finds your messages or maybe peers, but not all.
 - [X] Add log count to `pigeon-cli status`
 - [ ] Delete `Draft#put` entirely.
 - [ ] Check block list before ingesting bundles.
 - [ ] Update README.md / tutorial.rb (user manual for `Pigeon::Database`).
 - [ ] Make the switch to LevelDB, RocksDB, [UNQLite](https://unqlite.org/features.html) or similar (currently using Ruby PStore).
 - [ ] Need a way of importing / exporting a feeds blobs. (see "Bundle Brainstorming" below)
 - [ ] Need a way of adding peers messages / gossip to bundles. (see "Bundle Brainstorming" below)
 - [ ] add parsers and validators for all CLI inputs
 - [ ] Reduce whole darn repo into single module to aide portability. `::Helpers` module is OK.
 - [ ] Update the bundles.md document once `bundle consume` works.
 - [ ] 100% documentation
 - [ ] Update spec document CLI usage examples to reflect API changes in 2020.
 - [ ] Publish to RubyGems
 - [ ] Performance benchmarks (Do this second to last!)
 - [ ] Performance tuning (Do this last!)

# After v0.0.1

 - [ ] (later, not now) Support partial verification via `lipmaa` property.
 - [ ] Add mandatory `--since=` arg to `bundle create
 - [ ] Interest and Disinterest Signalling for document routing: Create a `$gossip` message to express `blob.have`, `blob.want` and to note last message received of a peer. This can steer bundle creation and an eventual `--for` flag at bundle creation time to customize a bundle to a particular user.

# Idea Bin

 - [ ] Map/reduce plugin support for custom indices?
 - [ ] Ability to add a blob in one swoop using File objects and `Message#[]=`, maybe?

# New Bundle Format

We have a bundle format that works, but it only exports messages.

We need a bundle format that may optionally include blobs as well.

Here's how we will support that:

1. Create a `bundle_X/` directory. The name is arbitrary and can be defined by the user.
2. In the root directory of `bundle_x/`, a single `messages.pgn` file contains all messages.
  * All messages are expected to be sorted by depth
  * Messages from multiple authors may be included in a single bundle, but the messages must appear in the correct order with regards to the `depth` field.
3. Blobs are stored in a very specific hierarchy to maintain FAT compatibility:
    * `blobs/sha256/AAAAAAAA/BBBBBBBB/CCCCCCCC/DDDDDDDD/EEEEEEEE/FFFFFFFF/G.HHH`

Additional notes:

 * It is recommended to compress bundles (ex: *.zip files) but these concerns are not handled by the protocol currently.

# Unanswered Questions

 * PEER MESSAGES: I want to add a `--depth` option to bundle exports that would only return messages after the `nth` sequence number. It would not make sense to apply `--depth` to all peer messages in the bundle. It would not be practical to expect the user to provide a `--depth` for every peer every time a bundle is generated.
   * Create a new `received_on` index that records the local user's `depth` at the time of ingestion?