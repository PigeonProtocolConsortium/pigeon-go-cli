package main

import (
	"database/sql"
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
	migration{
		up: `CREATE TABLE IF NOT EXISTS messages (
			id        INTEGER PRIMARY KEY AUTOINCREMENT,
			author    string NOT NULL,
			depth     int    NOT NULL,
			kind      string NOT NULL,
			lipmaa    string NOT NULL,
			prev      string NOT NULL,
			signature string NOT NULL,
			mhash     string NOT NULL
		);
		`,
		down: `DROP TABLE IF EXISTS messages`,
	},
	migration{
		up: `CREATE TABLE IF NOT EXISTS body_items (
			parent  int    NOT NULL,
			key     string NOT NULL,
			value   string NOT NULL,
			rank    int    NOT NULL,
			FOREIGN KEY(parent) REFERENCES messages(id)
		);
		`,
		down: `DROP TABLE IF EXISTS body_items`,
	},
}

func migrateUp(db *sql.DB) {
	tx, err := db.Begin()

	if err != nil {
		panicf("Failed to start transaction: %s", err)
	}

	for i, migration := range migrations {
		_, err := tx.Exec(migration.up)
		if err != nil {
			panicf("Migration failure(%d): %s", i, err)
		}
	}

	if tx.Commit() != nil {
		panic(err)
	}
}
