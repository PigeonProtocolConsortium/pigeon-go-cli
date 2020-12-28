# Pigeon CLI

A single executable to manage a Pigeon node.

# Project Status

HIBERNATION. Pigeon was an exploration of ideas that I embarked on in 2020. Now (2021) I am changing my focus. If more people are interested in the project I might start work on it again. Please let me know by raising an issue. For now, I am shifting my focus to other areas.

Please see the "TODO" section for a list of incomplete tasks. As of early 2021, the next big TODO item is to finish bundle imports.

# Setup

By default, data is stored in `~/.pigeon`.
You can override this value by specifying a `PIGEON_PATH` ENV var.

# Help Wanted

Raise an issue to get involved.

 * Writing a BNF grammar for message parsing
 * Test coverage increases
 * Manual QA of features and edge cases
 * Providing constructive feedback on documentation
 * Cross-compiling windows binaries
 * Security auditing and vulnerability discovery. Please send security concerns to [Rick Carlino](https://github.com/RickCarlino) privately.

# TODO

 - [ ] Add forgery protection tests
 - [ ] Add a real testing lib to DRY things up.
 - [ ] Validate and scrutinize `depth`, `prev` fields when ingesting message bundles to account for poorly written peer clients.
 - [ ] Get a good CI system going? Run tests at PR time, provide prebuilt binaries, prevent coverage slips, etc..
 - [ ] Add a `transact()` helper to ensure all transactions are closed out.
 - [ ] Switch to [SQLX](https://github.com/jmoiron/sqlx) for extra sanity.
 - [ ] Write docs for all CLI commands / args AFTER completion.
 - [ ] Start using the `check` helper instead of `error != nil`.
 - [ ] Update spec to only allow UPPERCASE MULTIHASHES
 - [ ] Implement `query.pgn` protocol, as outlined [here](%CSBzyskUxqbFSgOBh8OkVLn18NqX3zu3CF58mm2JHok=.sha256) and [here](%KWETmo1cmlfYK4N6FVL9BHYfFcKMy49E94XGuZSPGCw=.sha256).
 - [ ] Add a note about "shallow" vs. "deep" verification.
 - [ ] Finish all the things below

 |Done?|Noun        |Verb       | Flag / arg 1  | Flag 2    |
 |-----|------------|-----------|---------------|-----------|
 |     |bundle      |ingest     |               |           |
 |     |message     |show       | message mhash |           |
 |     |message     |find       | --all         |           |
 |     |blob        |remove     | mhash         |           |
 |     |message     |find       | --last        |           |
 |     |draft       |create     |               |           |
 |     |draft       |publish    |               |           |
 |     |draft       |show       |               |           |
 |     |draft       |update     | --key=?       | --value=? |
 |     |bundle      |create     |               |           |
 |  X  |blob        |find       |               |           |
 |  X  |blob        |add        | file path     |           |
 |  X  |blob        |add        | STDIO pipe    |           |
 |  X  |peer        |untrack    | peer mhash    |           |
 |  X  |peers       |list       |               |           |
 |  X  |peer        |block      | peer mhash    |           |
 |  X  |peer        |follow     | peer mhash    |           |
 |  X  |identity    |show       |               |           |
 |  X  |identity    |create     |               |           |
 |  X  |help        |           |               |           |
 |  X  |version     |           |               |           |

# Run Tests

Without coverage:

```
./tests.sh
```

With coverage:

```
./coverage.sh
```

# Build Project

```
./build.sh
```
