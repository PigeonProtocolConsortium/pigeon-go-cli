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
 - [ ] Stop using base64 in favor of base32 with no padding? Simplifies support for legacy systems. Easy to implement.
 - [ ] Need a way of importing / exporting a feeds blobs. (see "Bundle Brainstorming" below)
 - [ ] Need a way of adding a peers messages / blobs to bundles. (see "Bundle Brainstorming" below)
 - [ ] refactor `Bundle.create` to use `message find-all`.
 - [ ] Add mandatory `--from=` arg to `bundle create`
 - [ ] Make the switch to LevelDB, RocksDB or similar (currently using Ruby PStore).
 - [ ] Change all multihashes to Base32 to support case-insensitive file systems?
 - [ ] Rename (RemoteIdentity|LocalIdentity)#public_key to #multihash for consistency with other types.
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
 - [ ] Add `.pigeon` file extensions
 - [ ] Add Lipmaa links like the Bamboo folks do.
 - [ ] Ensure all disks writes perform verification!
 - [ ] Publish a RubyGem
 - [ ] 100% documentation
 - [ ] Update spec document CLI usage examples to reflect API changes in 2020.
 - [ ] Performance benchmarks (Do this second to last!)
 - [ ] Performance tuning (Do this last!)

# Idea Bin
 - [ ] Map/reduce plugin support for custom indices?
 - [ ] Ability to add a blob in one swoop using File objects and `Message#[]=`, maybe?

# Bundle Brainstorming

Bundles export need to export two things:
 * Messages
 * Blobs

Currently, we're only exporting messages.
We need to export both, though.

## Idea: Output a directory (Zip it Yourself)

1. Create a `bundle_X/` directory. The name is arbitrary and can be defined by the user.
2. In the root directory of `bundle_x/`, a single `messages.pgn` file contains all messages.
  * All messages are expected to be sorted by depth
  * Messages from multiple authors may be included in a single bundle, but the messages must apear in the correct order with regards to the `depth` field.
3. Blobs are stored in a very specific hierarchy to maintain FAT compatibility:
  * Blob multihashes are decoded from URL safe b64
  * Option I:
    * Blobs are re-encoded into base32 without padding (to support legacy filesystems)
  * Option II (not safe for FAT16?):
    * Blobs are encoded as Base16:
    * `xxxxxxxxxxxxxxxx/blobs/sha256/HEZB3/IFXHL4Y3/H4MWGKZV/42VVMO4S.4VQ`
    * `N` represents a single character in a blob's multihash

# Why Base32?

I want to support things like:

 * Hosting bundles on file servers (SFTP, HTTP, etc..)
 * Ingesting blobs on constraints devices (Eg: FAT16 filesystems, retro machines)

To do that:

 * Base 16 (hex) creates blob filenames that are too long for FAT16 and visually awkward.
 * Base64 can't be hosted on a web server
 * URLsafeBase64 can't be used on case insensitive file systems

