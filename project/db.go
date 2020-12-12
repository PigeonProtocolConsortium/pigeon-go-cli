package main

import (
	"database/sql"
	"path"

	_ "github.com/mattn/go-sqlite3"
)

func openDB() *sql.DB {
	pigeonPath := maybeSetupPigeonDir()
	dbPath := path.Join(pigeonPath, "db.sqlite")
	db, err0 := sql.Open("sqlite3", dbPath)

	check(err0, "failed to open db: %s", err0)

	err1 := db.Ping()

	check(err1, "failed to ping db: %s", err1)

	migrateUp(db)

	return db
}

// Database is a database object. Currently using modernc.org/ql
var database *sql.DB

func getDB() *sql.DB {
	if database != nil {
		return database
	}

	database = openDB()
	return database
}

// SetConfig will write a key/value pair to the `configs`
// table
func SetConfig(key string, value []byte) {
	tx, err := getDB().Begin()
	check(err, "Failed to SetConfig (0): %s", err)
	_, err2 := tx.Exec("INSERT INTO configs(key, value) VALUES(?1, ?2)", key, string(value))
	check(err2, "Failed to SetConfig (1): %s", err2)
	err1 := tx.Commit()
	check(err1, "Failed to SetConfig (2): %s", err1)
}

// GetConfig retrieves a key/value pair (or error) from the database.
func GetConfig(key string) ([]byte, error) {
	var result string
	row := getDB().QueryRow("SELECT value FROM configs WHERE key=$1", key)
	err := row.Scan(&result)
	if err != nil {
		return []byte{}, nil
	}
	return []byte(result), nil
}

// FetchConfig retrieves a key/value pair from the database.
// Fetching an unset key will result in a panic.
func FetchConfig(key string) []byte {
	result, err := GetConfig(key)
	check(err, "Something else went wrong: %s", err)
	return []byte(result)
}
