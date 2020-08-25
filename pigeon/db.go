package pigeon

import (
	"database/sql"
	"log"

	"modernc.org/ql"
)

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

	db.Exec(`
	CREATE TABLE private_keys (
		id INTEGER PRIMARY KEY,
		secret TEXT NOT NULL
	);
	`)
	return db
}

// Database is a database object. Currently using modernc.org/ql
var Database = openDB()

func setUp(db *sql.DB) error {
	tx, err := db.Begin()
	if err != nil {
		return err
	}
	_, err = tx.Exec(`
	CREATE TABLE note (
	  id BIGINT
	  ,title STRING
	  ,body STRING
	  ,created_at STRING
	  ,updated_at STRING
	);
	`)
	if err != nil {
		return err
	}
	if err = tx.Commit(); err != nil {
		return err
	}
	return nil
}

func tearDown(db *sql.DB) error {
	tx, err := db.Begin()
	if err != nil {
		return err
	}
	_, err = tx.Exec(`
	DROP TABLE note;
	`)
	if err != nil {
		return err
	}
	if err = tx.Commit(); err != nil {
		return err
	}
	return nil
}
