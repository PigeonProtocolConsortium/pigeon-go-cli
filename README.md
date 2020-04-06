![](logo.png)

# Pigeon Ruby

A WIP pigeon protocol client.

# How to Use

This is a pre-release skeleton project. There is no gem yet. The gem will be released after we are fully compliant with the spec and have high test coverage stats.

To get started, clone this repo and run `./pigeon-cli` in place of `pigeon`.

Eg: `pigeon identity show` becomes `./pigeon-cli show`.

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
 - [ ] Rename (RemoteIdentity|LocalIdentity)#public_key to #multihash for consistency with other types.
 - [ ] refactor `Bundle.create` to use `message find-all`.
 - [ ] Need a way of importing / exporting a feeds blobs. (see "Bundle Brainstorming" below)
 - [ ] Need a way of adding peers messages / gossip to bundles. (see "Bundle Brainstorming" below)
 - [ ] Add Lipmaa links like the Bamboo folks do.
 - [ ] Add mandatory `--since=` arg to `bundle create`
 - [ ] Make the switch to LevelDB, RocksDB or similar (currently using Ruby PStore).
 - [ ] Rename `message find` to `message read`, since other finders return a multihash.
 - [ ] Don't allow any type of whitespace in `kind` or `string` keys. Write a test for this.
 - [ ] Check block list before ingesting bundles.
 - [ ] Create regexes in ::Lexer using strings and Regexp.new() for cleaner regexes.
 - [ ] Handle the three outcomes of bundle ingestion: `ok`, `blocked`, `already_saved`.
 - [ ] add parsers and validators for all CLI inputs
 - [ ] Remove all `.current` "singletons" / hacks
 - [ ] Reduce whole darn repo into single module to aide portability. Maybe a second `::Support` module is OK.
 - [ ] Update the bundles.md document once `bundle consume` works.
 - [ ] Use URNs instead of multihash?
 - [ ] Ensure all disks writes perform verification!
 - [ ] Publish a RubyGem
 - [ ] 100% documentation
 - [ ] Update spec document CLI usage examples to reflect API changes in 2020.
 - [ ] Performance benchmarks (Do this second to last!)
 - [ ] Performance tuning (Do this last!)

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