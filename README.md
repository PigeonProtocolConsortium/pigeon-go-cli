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
 - [ ] pigeon draft create
 - [ ] pigeon draft append
 - [ ] pigeon draft current
 - [ ] pigeon draft save
 - [ ] Perform message verification at time of disk write
 - [ ] Remove all `.current` "singletons" / hacks
 - [ ] pigeon message find
 - [ ] pigeon message find-all
 - [ ] pigeon bundle create
 - [ ] pigeon bundle consume
 - [ ] 100% documentation
 - [ ] add parsers and validators for all CLI inputs
 - [ ] Validate inputs for `Draft#[]=`.
 - [ ] Update spec to look [like this](https://gist.github.com/RickCarlino/3ff4178db4a75fd135832c403cd313d4)
 - [ ] Reduce whole darn repo into single module to aide portability
 - [ ] Add Lipmaa links like the Bamboo folks do.
 - [ ] Publish a RubyGem
 - [ ] Performance benchmarks
 - [ ] Performance tuning (DO THIS LAST!)

# Idea Bin
 - [ ] Map/reduce plugin support for custom indices?
 - [ ] Ability to add a blob in one swoop using File objects and `Message#[]=`, maybe?
