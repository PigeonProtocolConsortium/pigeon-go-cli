package pigeon

import (
	"testing"
)

func TestSetUp(t *testing.T) {
	db := openDB()
	err := db.Ping()
	if err != nil {
		t.Fail()
	}
}
