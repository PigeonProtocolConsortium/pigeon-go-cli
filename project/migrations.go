package main

import (
	"database/sql"
	"log"
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
	migration{
		up: `CREATE TABLE IF NOT EXISTS peers (
			mhash string NOT NULL,
			status string NOT NULL
		);
		CREATE UNIQUE INDEX IF NOT EXISTS unique_peers_mhash ON peers (mhash);
		`,
		down: `DROP TABLE IF EXISTS peers`,
	},
}

func migrateUp(db *sql.DB) {
	tx, err := db.Begin()

	if err != nil {
		log.Fatalf("Failed to start transaction: %s", err)
	}

	for i, migration := range migrations {
		_, err := tx.Exec(migration.up)
		if err != nil {
			log.Fatalf("Migration failure(%d): %s", i, err)
		}
	}

	if tx.Commit() != nil {
		log.Fatal(err)
	}
}
