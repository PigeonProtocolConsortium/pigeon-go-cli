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
 - [ ] Convert `".sig.ed25519"` literals to constants
 - [ ] Reduce whole darn repo into single module to aide portability
 - [ ] Remove all `.current` "singletons" / hacks
 - [ ] Rename numerous "pigeon message ..." commands to "pigeon draft ..."
 - [ ] pigeon bundle create
 - [ ] pigeon bundle consume
 - [ ] pigeon draft create
 - [ ] pigeon draft append
 - [ ] pigeon draft current
 - [ ] pigeon draft save
 - [ ] pigeon message find
 - [ ] pigeon message find-all
 - [ ] 100% documentation
 - [ ] add parsers and validators for all CLI inputs
 - [ ] Validate inputs for `Draft#[]=`.
 - [ ] Perform message verrification at time of disk write?
 - [ ] Performance benchmarks
 - [ ] Performance tuning (DO THIS LAST!)
 - [ ] Update spec to look [like this](https://gist.github.com/RickCarlino/3ff4178db4a75fd135832c403cd313d4)
 - [ ] Publish a RubyGem

# Idea Bin
 - [ ] Map/reduce plugin support for custom indices?
 - [ ] Add Lipmaa links like the Bamboo folks do.
 - [ ] Ability to add a blob in one swoop using File objects and `Message#[]=`, maybe?
