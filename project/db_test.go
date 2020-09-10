package main

import (
	"log"
	"testing"
)

func resetDB() {
	tx, err := Database.Begin()

	if err != nil {
		log.Fatalf("Failed to start transaction: %s", err)
	}

	for i := len(migrations) - 1; i >= 0; i-- {
		_, err := tx.Exec(migrations[i].down)
		if err != nil {
			log.Fatalf("Migration failure: %s", err)
		}
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
}

func TestSetUpTeardown(t *testing.T) {
	resetDB()
	db := Database
	err := db.Ping()
	if err != nil {
		t.Fatalf("Test setup failed: %s", err)
	}
}
