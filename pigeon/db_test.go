package pigeon

import (
	"testing"
)

func TestSetUpTeardown(t *testing.T) {
	db := openDB()
	err := db.Ping()
	if err != nil {
		t.Fail()
	}
}
