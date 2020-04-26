![](logo.png)

# Pigeon Ruby

A [Pigeon Protocol](https://tildegit.org/PigeonProtocolConsortium/protocol_spec) client written in Ruby.

# Features

 * CLI and API available (link to quick start for both here)
 * Minimal dependencies - only outside deps are `thor` (for CLI) and `ed25519` (for signatures).
 * Thoroughly unit tested.

# Caveats

 * Current windows support is unknown (and unlikely to work in current state). Please report bugs.
 * Not published to RubyGems yet (see installation instructions below)
 * Single threaded use is assumed and is intended for a single user per OS process. It makes many design tradeoffs around that use case.
 * Bundling operations need performance tuning. Optimizations are planned and help is welcome.

# Build From Source

We are not yet on Rubygems. The gem will be released after we are fully compliant with the spec and have high test coverage stats.

In the meantime:

```
git clone https://tildegit.org/PigeonProtocolConsortium/pigeon_ruby.git
cd pigeon_ruby
gem build pigeon.gemspec
gem install pigeon-0.1.1.gem
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

 - [ ] BUG: Keys that start with a carriage return (`\n`) freeze tokenizer.
 - [ ] Update README.md
 - [ ] Write tutorial.rb (user manual for `Pigeon::Database`).
 - [ ] Convert literals to constants, remove unused locals, reduce duplication, run linter.
 - [ ] 100% class / module documentation
 - [ ] Update spec document CLI usage examples to reflect API changes in 2020.
 - [ ] Publish to RubyGems

# Optimizations

 - [ ] add parsers and validators for all CLI inputs
 - [ ] Make the switch to LevelDB, RocksDB, [UNQLite](https://unqlite.org/features.html) or similar (currently using Ruby PStore).
 - [ ] Reduce whole darn repo into single module to aide portability. `::Helpers` module is OK.
 - [ ] Update the bundles.md document once `bundle consume` works.
 - [ ] Performance benchmarks (Do this second to last!)
 - [ ] Performance tuning (Do this last!)

# New Features / Road Map

 - [ ] Support partial verification via `lipmaa` property.
 - [ ] Add `--since=`/`--until=` args to `bundle create` for sending partial / "slice" bundles.
 - [ ] Interest and Disinterest Signalling for document routing: Create a `$blob_status` message to express `have`, `want` signalling. This can steer bundle creation and an eventual `--for` flag at bundle creation time to customize a bundle to a particular user.
 - [ ] Add a schema for `$peer_status`. Eg: `block`, `unblock`, `follow`, `unfollow`.

# Idea Bin

 - [ ] Ability to add map/reduce plugins to support custom indices?
 - [ ] Ability to add a blob in one swoop using File objects and `Message#[]=`, maybe?
 - [ ] Bundling via [Optar](http://ronja.twibright.com/optar/) or [Colorsafe](https://github.com/colorsafe/colorsafe)

# New Bundle Format

We have a bundle format that works, but it only exports messages.

We need a bundle format that may optionally include blobs as well.

Here's how we will support that:

1. Create a `bundle_X/` directory. The name is arbitrary and can be defined by the user.
2. In the root directory of `bundle_x/`, a single `messages.pgn` file contains all messages.
  * All messages are expected to be sorted by depth
  * Messages from multiple authors may be included in a single bundle, but the messages must appear in the correct order with regards to the `depth` field.
3. Blobs are stored in a very specific hierarchy to maintain FAT compatibility:
    * `blobs/bundle/7Z2CSZK/MB1RE5G/6SKXRZ6/3ZGCNP8/VVEM3K0/XFMYKET/RDQSM5W.BSG`

Additional notes:

 * It is recommended to compress bundles (ex: *.zip files) but these concerns are not handled by the protocol currently.

# Unanswered Questions

 * PEER MESSAGES: I want to add a `--depth` option to bundle exports that would only return messages after the `nth` sequence number. It would not make sense to apply `--depth` to all peer messages in the bundle. It would not be practical to expect the user to provide a `--depth` for every peer every time a bundle is generated.
   * Create a new `received_on` index that records the local user's `depth` at the time of ingestion?
