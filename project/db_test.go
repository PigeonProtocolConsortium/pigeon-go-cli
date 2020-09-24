package main

import (
	"testing"
)

func resetDB() {
	tx, err := getDB().Begin()

	if err != nil {
		panicf("Failed to start transaction: %s", err)
	}

	for i := len(migrations) - 1; i >= 0; i-- {
		_, err := tx.Exec(migrations[i].down)
		if err != nil {
			panicf("Migration failure: %s", err)
		}
	}

	for _, migration := range migrations {
		_, err := tx.Exec(migration.up)
		if err != nil {
			panicf("Migration failure: %s", err)
		}
	}

	if tx.Commit() != nil {
		panic(err)
	}
}

func TestSetUpTeardown(t *testing.T) {
	resetDB()
	err := getDB().Ping()
	if err != nil {
		t.Fatalf("Test setup failed: %s", err)
	}
}
