# Pigeon CLI

A single executable to manage a Pigeon node.

# Project Status

Don't use the Go version yet. If you want something stable, there is a [Ruby version that is feature complete](https://tildegit.org/PigeonProtocolConsortium/Pigeon-Ruby).

# Setup

By default, data is stored in `~/.pigeon`.
You can override this value by specifying a `PIGEON_PATH` ENV var.

# TODO

 - [ ] Add a real testing lib to DRY things up.
 - [ ] Figure out a system for where to place the default data storage directory
 - [ ] Get a good CI system going? Run tests at PR time, provide prebuilt binaries, prevent coverage slips, etc..
 - [ ] Add a `transact()` helper to ensure all transactions are closed out.
 - [ ] Switch to [SQLX](https://github.com/jmoiron/sqlx) for extra sanity.
 - [ ] Finish all the things below:

 |Done?|Noun        |Verb       | Flag / arg 1  | Flag 2    |
 |-----|------------|-----------|---------------|-----------|
 |     |blob        |find       |               |           |
 |     |draft       |create     |               |           |
 |     |draft       |publish    |               |           |
 |     |draft       |show       |               |           |
 |     |draft       |update     | --key=?       | --value=? |
 |     |message     |find       | --all         |           |
 |     |message     |find       | --last        |           |
 |     |message     |show       | message mhash |           |
 |     |bundle      |create     |               |           |
 |     |bundle      |ingest     |               |           |
 |     |blob        |add        | pipe (later)  |           |
 |  X  |blob        |add        | file path     |           |
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
