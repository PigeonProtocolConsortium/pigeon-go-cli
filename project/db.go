package main

import (
	"database/sql"
	"log"

	"modernc.org/ql"
)

type migration struct {
	up   string
	down string
}

var migrations = []migration{
	migration{
		up: `CREATE TABLE IF NOT EXISTS configs (
			key string NOT NULL,
			value string NOT NULL
		);
		CREATE UNIQUE INDEX IF NOT EXISTS unique_configs_key ON configs (key);
		`,
		down: `DROP TABLE IF EXISTS configs`,
	},
}

func openDB() *sql.DB {
	ql.RegisterDriver()

	db, err0 := sql.Open("ql", "file://testdata/secret.db")

	if err0 != nil {
		log.Fatalf("failed to open db: %s", err0)
	}

	err1 := db.Ping()

	if err1 != nil {
		log.Fatalf("failed to ping db: %s", err1)
	}

	tx, err := db.Begin()

	if err != nil {
		log.Fatalf("Failed to start transaction: %s", err)
	}

	for _, migration := range migrations {
		_, err := tx.Exec(migration.up)
		if err != nil {
			log.Fatalf("Migration failure: %s", err)
		}
	}

	if tx.Commit() != nil {
		log.Fatal(err)
	}

	return db
}

// Database is a database object. Currently using modernc.org/ql
var Database = openDB()

// SetConfig will write a key/value pair to the `configs`
// table
func SetConfig(key string, value []byte) {
	tx, err := Database.Begin()
	if err != nil {
		log.Fatalf("Failed to SetConfig (0): %s", err)
	}
	_, err2 := tx.Exec("INSERT INTO configs(key, value) VALUES(?1, ?2)", key, string(value))
	if err2 != nil {
		log.Fatalf("Failed to SetConfig (1): %s", err2)
	}
	err1 := tx.Commit()
	if err1 != nil {
		log.Fatalf("Failed to SetConfig (2): %s", err)
	}
}

// GetConfig retrieves a key/value pair from the database.
func GetConfig(key string) []byte {
	var result string
	row := Database.QueryRow("SELECT value FROM configs WHERE key=$1", key)
	err := row.Scan(&result)
	if err != nil {
		if err == sql.ErrNoRows {
			log.Fatalf("CONFIG MISSING: %s", key)
		} else {
			panic(err)
		}
	}
	return []byte(result)
}
