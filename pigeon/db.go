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
		up:   `CREATE TABLE IF NOT EXISTS private_keys (id INTEGER PRIMARY KEY, secret TEXT NOT NULL);`,
		down: `DROP TABLE IF EXISTS private_keys`,
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

func tearDown() {
	tx, err := Database.Begin()

	if err != nil {
		log.Fatalf("Failed to start transaction: %s", err)
	}

	for _, migration := range migrations {
		tx.Exec(migration.down)
	}

	tx.Commit()
}
