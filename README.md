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
 - [ ] Finish all the things below:

 |Done?|Noun        |Verb       | Flag / arg 1  | Flag 2    |
 |-----|------------|-----------|---------------|-----------|
 |     |peers       |list       |               |           |
 |     |peer        |untrack    | peer mhash    |           |
 |     |blob        |create     | file path     |           |
 |     |blob        |create     | pipe          |           |
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
