# Pigeon CLI

A single executable to manage a Pigeon node.

# Project Status

Don't use the Go version yet. If you want sommething stable, there is a [Ruby version that is feature complete](https://tildegit.org/PigeonProtocolConsortium/Pigeon-Ruby).

# TODO

 - [ ] Finish all the things below:

 |Done?|Verb        |Noun    | Flag / arg 1  | Flag 2    |
 |-----|------------|--------|---------------|-----------|
 |     |block       |peer    | user mhash    |           |
 |     |create      |blob    | file Path     |           |
 |     |create      |blob    | pipe          |           |
 |     |create      |bundle  |               |           |
 |     |create      |draft   |               |           |
 |     |create      |identity|               |           |
 |     |find        |message | --all         |           |
 |     |find        |message | --last        |           |
 |     |follow      |peer    | user mhash    |           |
 |     |ingest      |bundle  |               |           |
 |     |show        |blob    |               |           |
 |     |show        |draft   |               |           |
 |     |show        |identity|               |           |
 |     |show        |message | message mhash |           |
 |     |show        |peers   |               |           |
 |     |show        |peers   | --blocked     |           |
 |     |sign        |draft   |               |           |
 |     |unblock     |peer    | user mhash    |           |
 |     |unfollow    |peer    |               |           |
 |     |update      |draft   | --key=?       | --value=? |
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
