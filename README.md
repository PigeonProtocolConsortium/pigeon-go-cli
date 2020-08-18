# Pigeon CLI

A single executable to manage a Pigeon node.

# Project Status

Don't use the Go version yet. If you want sommething stable, there is a [Ruby version that is feature complete](https://tildegit.org/PigeonProtocolConsortium/Pigeon-Ruby).

# TODO

 - [ ] Get a good CI system going? Run tests at PR time, prevent coverage slips, etc..
 - [ ] Finish all the things below:

 |Done?|Verb        |Noun    | Flag / arg 1  | Flag 2    |
 |-----|------------|--------|---------------|-----------|
 |     |create      |identity|               |           |
 |     |show        |identity|               |           |
 |     |create      |draft   |               |           |
 |     |show        |blob    |               |           |
 |     |show        |draft   |               |           |
 |     |create      |blob    | file path     |           |
 |     |create      |blob    | pipe          |           |
 |     |update      |draft   | --key=?       | --value=? |
 |     |publish     |draft   |               |           |
 |     |follow      |peer    | user mhash    |           |
 |     |unblock     |peer    | user mhash    |           |
 |     |block       |peer    | user mhash    |           |
 |     |create      |bundle  |               |           |
 |     |find        |message | --all         |           |
 |     |find        |message | --last        |           |
 |     |ingest      |bundle  |               |           |
 |     |show        |message | message mhash |           |
 |     |show        |peers   |               |           |
 |     |show        |peers   | --blocked     |           |
 |     |unfollow    |peer    |               |           |
 |  X  |help        |        |               |           |
 |  X  |version     |        |               |           |

# Run Tests

Without coverage:

```
go test ./cmd
```

With coverage:

```
go test ./cmd -coverprofile cp.out
```

# Build Project

```
go build --o=pigeon-cli
```
