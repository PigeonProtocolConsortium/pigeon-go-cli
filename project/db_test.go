package main

import (
	"os/exec"
	"testing"
)

func resetDB() {
	tx, err := getDB().Begin()

	check(err, "Failed to start transaction: %s", err)

	for i := len(migrations) - 1; i >= 0; i-- {
		_, err := tx.Exec(migrations[i].down)
		check(err, "Migration #%d failure: %s", i, err)
	}

	for _, migration := range migrations {
		_, err := tx.Exec(migration.up)
		check(err, "Migration failure: %s", err)
	}

	err7 := tx.Commit()
	check(err7, "TEST FAILURE db_test.go: %s", err7)

	exec.Command("rm", "-rf", pigeonBlobDir())
}

func TestSetUpTeardown(t *testing.T) {
	resetDB()
	err := getDB().Ping()
	check(err, "Test setup failed: %s", err)
}
