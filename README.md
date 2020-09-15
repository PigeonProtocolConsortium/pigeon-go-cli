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

 |Done?|Verb        |Noun       | Flag / arg 1  | Flag 2    |
 |-----|------------|-----------|---------------|-----------|
 |     |peer        |block      | peer mhash    |           |
 |     |peer        |follow     | peer mhash    |           |
 |     |peer        |show       |               |           |
 |     |peer        |show       | --blocked     |           |
 |     |peer        |unblock    | peer mhash    |           |
 |     |peer        |unfollow   |               |           |
 |     |blob        |create     | file path     |           |
 |     |blob        |create     | pipe          |           |
 |     |bundle      |create     |               |           |
 |     |draft       |create     |               |           |
 |     |blob        |find       |               |           |
 |     |message     |find       | --all         |           |
 |     |message     |find       | --last        |           |
 |     |bundle      |ingest     |               |           |
 |     |draft       |publish    |               |           |
 |     |draft       |show       |               |           |
 |     |message     |show       | message mhash |           |
 |     |draft       |update     | --key=?       | --value=? |
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
