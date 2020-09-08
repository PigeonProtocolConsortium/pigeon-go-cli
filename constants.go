package main

// Version is the current version of Pigeon CLI
const Version = "0.0.0"

// BlobSigil is a string identifier that precedes a base32
// hash (SHA256) representing arbitrary data.
const BlobSigil = "FILE."

// MessageSigil is a string identifier that precedes a base32
// hash (SHA256) representing arbitrary data.
const MessageSigil = "TEXT."

// UserSigil is a string identifier that precedes a base32
// representation of a particular user's ED25519 public key.
const UserSigil = "USER."

// StringSigil is a character used to identify strings as
// defined by the pigeon protocol spec.
const StringSigil = "\""

// DefaultDBPath describes the default storage location for
// the database instance.
const DefaultDBPath = "./pigeondb"
