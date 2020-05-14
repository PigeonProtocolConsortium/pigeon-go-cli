![](logo.png)

# Pigeon Ruby

A [Pigeon Protocol](https://tildegit.org/PigeonProtocolConsortium/protocol_spec) client written in Ruby.

Email `contact` at `vaporsoft.xyz` to ask questions or get involved. Your feedback is solicited and appreciated. Seriously, send us an email! We look forward to hearing from you.

# Features

 * CLI (docs via `pigeon-cli help`) and Ruby API available ([docs here](ruby_tutorial.md))
 * Minimal dependencies - only outside deps are `thor` (for CLI) and `ed25519` (for signatures).
 * Thoroughly unit tested.

# Caveats

 * Current windows support is unknown (and unlikely to work in current state). Please report bugs.
 * Not published to RubyGems yet (see installation instructions below)
 * Single threaded use is assumed. Built for a single user per OS process. Many design tradeoffs were made around that use case.
 * Bundling operations need performance tuning. Optimizations are planned and help is welcome.

# Build From Source

We are not yet on Rubygems. The gem will be released after we are fully compliant with the spec.

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

[Docs available here](ruby_tutorial.md)

# Current Status

 - [ ] Change message templates to render headers in this order: `author`, `prev`, `lipmaa`, `depth`, `kind`.
 - [ ] Make location of blob folder configurable?
 - [ ] Change `@`, `%`, `&` to `feed.`, `mesg.`, `blob.`, respectively. Better readability, easier onboarding, URL friendly.
 - [ ] Update Dev docs in protocol spec to reflect changes to `lipmaa` header.
 - [ ] Update spec document CLI usage examples to reflect API changes in 2020.
 - [ ] 100% class / module documentation
 - [ ] Run a [terminology extraction tool](https://www.visualthesaurus.com/vocabgrabber/#) on the documentation and write a glossary of terms.
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

 - [ ] Ability to add map/reduce plugins to support custom indices?
 - [ ] Ability to add a blob in one swoop using File objects and `Message#[]=`, maybe?
 - [ ] Bundling via [Optar](http://ronja.twibright.com/optar/) or [Colorsafe](https://github.com/colorsafe/colorsafe)
