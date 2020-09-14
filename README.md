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

 |Done?|Verb        |Noun    | Flag / arg 1  | Flag 2    |
 |-----|------------|--------|---------------|-----------|
 |     |follow      |peer    | user mhash    |           |
 |     |show        |peers   |               |           |
 |     |show        |peers   | --blocked     |           |
 |     |block       |peer    | user mhash    |           |
 |     |unblock     |peer    | user mhash    |           |
 |     |unfollow    |peer    |               |           |
 |     |create      |blob    | file path     |           |
 |     |create      |blob    | pipe          |           |
 |     |create      |bundle  |               |           |
 |     |create      |draft   |               |           |
 |     |find        |blob    |               |           |
 |     |find        |message | --all         |           |
 |     |find        |message | --last        |           |
 |     |ingest      |bundle  |               |           |
 |     |publish     |draft   |               |           |
 |     |show        |draft   |               |           |
 |     |show        |message | message mhash |           |
 |     |update      |draft   | --key=?       | --value=? |
 |  X  |show        |identity|               |           |
 |  X  |create      |identity|               |           |
 |  X  |help        |        |               |           |
 |  X  |version     |        |               |           |

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
