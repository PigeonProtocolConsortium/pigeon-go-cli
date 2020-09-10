# Pigeon CLI

A single executable to manage a Pigeon node.

# Project Status

Don't use the Go version yet. If you want something stable, there is a [Ruby version that is feature complete](https://tildegit.org/PigeonProtocolConsortium/Pigeon-Ruby).

# TODO

 - [ ] Finish http://go-database-sql.org/nulls.html
 - [ ] Fix go module nonsense. Read a tut or sth https://thenewstack.io/understanding-golang-packages/
 - [ ] Add a real testing lib to DRY things up.
 - [ ] Get a good CI system going? Run tests at PR time, provide prebuilt binaries, prevent coverage slips, etc..
 - [ ] Finish all the things below:

 |Done?|Verb        |Noun    | Flag / arg 1  | Flag 2    |
 |-----|------------|--------|---------------|-----------|
 |     |show        |peers   |               |           |
 |     |show        |peers   | --blocked     |           |
 |     |unfollow    |peer    |               |           |
 |     |follow      |peer    | user mhash    |           |
 |     |unblock     |peer    | user mhash    |           |
 |     |block       |peer    | user mhash    |           |
 |     |show        |blob    |               |           |
 |     |create      |blob    | file path     |           |
 |     |create      |blob    | pipe          |           |
 |     |create      |draft   |               |           |
 |     |update      |draft   | --key=?       | --value=? |
 |     |show        |draft   |               |           |
 |     |publish     |draft   |               |           |
 |     |create      |bundle  |               |           |
 |     |find        |message | --all         |           |
 |     |find        |message | --last        |           |
 |     |ingest      |bundle  |               |           |
 |     |show        |message | message mhash |           |
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
go build --o=pigeon-cli
```
