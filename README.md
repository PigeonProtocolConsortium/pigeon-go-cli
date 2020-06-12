![](logo.png)

# Pigeon Ruby

A [Pigeon Protocol](https://tildegit.org/PigeonProtocolConsortium/protocol_spec) client written in Ruby.

Email `contact` at `vaporsoft.xyz` to ask questions or get involved. Your feedback is solicited and appreciated. Seriously, send us an email! We look forward to hearing from you.

# Features

 * CLI (docs via `pigeon-cli help`) and Ruby API available ([docs here](ruby_tutorial.md))
 * Minimal dependencies - only outside deps are `thor` (for CLI) and `ed25519` (for signatures).
 * Thoroughly unit tested.

# Caveats

 * Implementation is assumed to be stable, but does not have much production use.
 * Windows support is unknown (and unlikely to work in current state). Please report bugs.
 * Single threaded use is assumed. Built for a single user per OS process. Many design tradeoffs were made around that use case.
 * Bundling operations need performance tuning. Optimizations are planned and help is welcome.

# Installation - Bundler (Easy)

Add this to you Gemfile:

```
gem "pigeon",
  git: "https://tildegit.org/PigeonProtocolConsortium/pigeon_ruby",
  tag: "v0.2.0"
```

Then run

```
bundle install
```

# Usage: CLI

See `pigeon-cli help` for documentation.
See `kitchen_sink.sh` examples.

# Usage: Ruby Lib

[Docs available here](ruby_tutorial.md)

# Current Status

 - [ ] Update spec document CLI usage examples to reflect API changes in 2020.
 - [ ] Ability to unblock someone.
 - [ ] Ability to delete a key from a draft.
 - [ ] Update Dev docs in protocol spec to reflect changes to `lipmaa` header.
 - [ ] 100% class / module documentation
 - [ ] Run a [terminology extraction tool](https://www.visualthesaurus.com/vocabgrabber/#) on the documentation and write a glossary of terms.
 - [ ] Ability to list all blocked users.
 - [ ] Ability to unblock a user.

# "Nice to Have"

 - [ ] Support partial verification via `lipmaa` property.
 - [ ] Add `--since=`/`--until=` args to `bundle create` for sending partial / "slice" bundles.
 - [ ] Interest and Disinterest Signalling for document routing: Create a `$blob_status` message to express `have`, `want` signalling. This can steer bundle creation and an eventual `--for` flag at bundle creation time to customize a bundle to a particular user.
 - [ ] Add a schema for `$peer_status`. Eg: `block`, `unblock`, `follow`, `unfollow`.

# Idea Bin

 - [ ] Ability to add map/reduce plugins to support custom indices?
 - [ ] Bundling via [Optar](http://ronja.twibright.com/optar/) or [Colorsafe](https://github.com/colorsafe/colorsafe)
 - [ ] Ability to add map/reduce plugins to support custom indices?
 - [ ] Ability to add a blob in one swoop using File objects and `Message#[]=`, maybe?
 - [ ] Bundling via [Optar](http://ronja.twibright.com/optar/) or [Colorsafe](https://github.com/colorsafe/colorsafe)
