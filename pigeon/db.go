package pigeon

import (
	"log"

	"github.com/xujiajun/nutsdb"
)

// Database will open the NutsDB database.
func createDB() *nutsdb.DB {
	// Open the database located in the /tmp/nutsdb directory.
	// It will be created if it doesn't exist.
	opt := nutsdb.DefaultOptions
	opt.Dir = "./pigeondb"
	db, err := nutsdb.Open(opt)
	if err != nil {
		log.Fatal(err)
	}
	return db
}

var database = createDB()
var configBucket = "config"

// A ConfigKey represents a key used within the NutsDB
// "config" bucket.
type ConfigKey string

const (
	// ConfigSecret is the binary representation of the users
	// ED25519 secret key.
	ConfigSecret ConfigKey = "secret"
)

// PutConfig writes a configuration value to NutsDB
func PutConfig(k ConfigKey, v []byte) {
	database.Update(func(tx *nutsdb.Tx) error {
		err1 := tx.Put(configBucket, []byte(k), v, 0)
		if err1 != nil {
			log.Fatal(err1)
		}
		err2 := tx.Commit()
		if err2 != nil {
			log.Fatal(err2)
		}
		return nil
	})
}

// GetConfig retrieves aconfiguration key from NutsDB
func GetConfig(k ConfigKey) []byte {
	var output []byte
	database.View(
		func(tx *nutsdb.Tx) error {
			val, err1 := tx.Get(configBucket, []byte(k))
			if err1 != nil {
				log.Fatal(err1)
			}
			output = val.Value
			return nil
		})
	return output
}
