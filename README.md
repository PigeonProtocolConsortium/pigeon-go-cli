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
 - [ ] Handle the three outcomes of bundle ingestion: `ok`, `blocked`, `already_saved`.
 - [ ] Check blocklist before ingesting bundles.
 - [ ] Rename (RemoteIdentity|LocalIdentity)#public_key to #multihash for consistency with other types.
 - [ ] Rename `message find` to `message read`, since other finders return a multihash.
 - [ ] Don't allow carriage return in `kind` or `string` keys. Write a test for this.
 - [ ] Create regexes in ::Lexer using strings and Regexp.new() for cleaner regexes.
 - [ ] Ensure all disks writes perform verification!
 - [ ] Implement pigeon message find-all for peer feed. I will need to add index for `author => message_count`
 - [ ] refactor `Bundle.create` to use `message find-all`.
 - [ ] add parsers and validators for all CLI inputs
 - [ ] Remove all `.current` "singletons" / hacks
 - [ ] Reduce whole darn repo into single module to aide portability. Maybe a second `::Support` module is OK.
 - [ ] 100% documentation
 - [ ] 100% test coverage
 - [ ] Update the bundles.md document once `bundle consume` works.
 - [ ] Use URNs instead of multihash?
 - [ ] Add `.pigeon` file extensions
 - [ ] Update spec to look [like this](https://gist.github.com/RickCarlino/3ff4178db4a75fd135832c403cd313d4)
 - [ ] Add Lipmaa links like the Bamboo folks do.
 - [ ] Publish a RubyGem
 - [ ] Performance benchmarks
 - [ ] Performance tuning (DO THIS LAST!)

# Idea Bin
 - [ ] Map/reduce plugin support for custom indices?
 - [ ] Ability to add a blob in one swoop using File objects and `Message#[]=`, maybe?
