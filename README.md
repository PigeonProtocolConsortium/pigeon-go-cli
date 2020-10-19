# Pigeon CLI

A single executable to manage a Pigeon node.

# Project Status

Don't use the Go version yet. If you want something stable, there is a [Ruby version that is feature complete](https://tildegit.org/PigeonProtocolConsortium/Pigeon-Ruby).

# Setup

By default, data is stored in `~/.pigeon`.
You can override this value by specifying a `PIGEON_PATH` ENV var.

# Help Wanted

Want to get involved? Below are a few things I need help with.

Email `contact@vaporsfot.xyz` if you have any questions.

 * Writing a BNF grammar for message parsing
 * Test coverage increases
 * Manual QA of features and edge cases
 * Providing constructive feedback on documentation
 * Cross-compiling windows binaries
 * General Golang help (I am a Golang novice- project structure could be improved)
 * Security auditing and vulnerability discovery. Please send security concerns to `contact@vaporsoft.xyz` privately.

# TODO

 - [ ] Add a real testing lib to DRY things up.
 - [ ] Get a good CI system going? Run tests at PR time, provide prebuilt binaries, prevent coverage slips, etc..
 - [ ] Add a `transact()` helper to ensure all transactions are closed out.
 - [ ] Switch to [SQLX](https://github.com/jmoiron/sqlx) for extra sanity.
 - [ ] Write docs for all CLI commands / args AFTER completion.
 - [ ] Finish all the things below:

# Protocol Changes?

 - [ ] Rename `lipmaa` to `backlink` as Bamboo protocol has done?
 - [ ] Don't enforce a structure on how blobs are packed into bundles- the client is forced to determine the SHA checksum regardless. Forced structure just complicates protocol design.
 - [ ] Mandate usage of ZIP files so that bundles are always a single file?

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
