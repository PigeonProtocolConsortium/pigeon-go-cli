package pigeon

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
			id    INTEGER PRIMARY KEY,
			key   TEXT NOT NULL
			value TEXT NOT NULL);`,
		down: `DROP TABLE IF EXISTS configs`,
	},
}

func openDB() *sql.DB {
	ql.RegisterDriver()

	db, err0 := sql.Open("ql", "file://pigeon_metadata/secret.db")

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
		tx.Exec(migration.up)
	}

	tx.Commit()

	return db
}

// Database is a database object. Currently using modernc.org/ql
var Database = openDB()

// SetConfig will write a key/value pair to the `configs`
// table
func SetConfig(key string, value []byte) {
	tx, err := Database.Begin()
	if err != nil {
		log.Fatalf("Failed to SetConfig (1): %s", err)
	}
	tx.Exec("INSERT INTO configs (?, ?)", key, value)
	err1 := tx.Commit()
	if err1 != nil {
		log.Fatalf("Failed to SetConfig (2): %s", err)
	}
}

// GetConfig retrieves a key/value pair from the database.
func GetConfig(key string) []byte {
	rows, err := Database.Query("SELECT key FROM configs WHERE value = ? LIMIT 1", key)
	if err != nil {
		log.Fatalf("Unable to retrieve config key(1): %s", err)
	}
	var result []byte
	for rows.Next() {
		err := rows.Scan(&result)
		if err != nil {
			log.Fatalf("Unable to retrieve config key(2): %s", err)
		}
	}

	return result
}
