package main

import (
	"database/sql"
	"log"
	"path"

	"modernc.org/ql"
)

func openDB() *sql.DB {
	ql.RegisterDriver()
	pigeonPath := maybeSetupPigeonDir()
	dbPath := path.Join(pigeonPath, "db")
	db, err0 := sql.Open("ql", dbPath)

	if err0 != nil {
		log.Fatalf("failed to open db: %s", err0)
	}

	err1 := db.Ping()

	if err1 != nil {
		log.Fatalf("failed to ping db: %s", err1)
	}

	migrateUp(db)

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
