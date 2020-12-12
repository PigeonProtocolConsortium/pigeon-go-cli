package main

const messageExistsQuery = "SELECT count(*) FROM messages WHERE mhash = $1"

func messageExists(mhash string) bool {
	var count int
	db := getDB()
	result := db.QueryRow(messageExistsQuery, mhash)
	err := result.Scan(&count)
	check(err, "Error in messageExists: %s", err)
	if count == 1 {
		return true
	}
	return false
}
