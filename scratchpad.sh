#!/usr/bin/env fish

# This is a script that
# run all CLI commands at once
# for quick QA.

echo "Deleting old pigeon configs"
rm -f db.pigeon
rm -f pigeon.bundle
echo "OK"

echo "Creating new config:"
./pigeon-cli identity new
./pigeon-cli identity show

echo "Creating kitty cat blobs:"
cat scratchpad.jpg | ./pigeon-cli blob set

echo "Adding peers:"
echo "FIX THESE!!! THEY ARE STILL b64"
./pigeon-cli peer add @CHANGE_THIS_TO_BASE_32.ed25519
./pigeon-cli peer add @CHANGE_THIS_TO_BASE_32.ed25519
./pigeon-cli peer add @CHANGE_THIS_TO_BASE_32.ed25519
./pigeon-cli peer add @CHANGE_THIS_TO_BASE_32.ed25519
./pigeon-cli peer add @CHANGE_THIS_TO_BASE_32.ed25519
./pigeon-cli peer add @CHANGE_THIS_TO_BASE_32.ed25519
./pigeon-cli peer add @CHANGE_THIS_TO_BASE_32.ed25519
./pigeon-cli peer add @CHANGE_THIS_TO_BASE_32.ed25519

echo "removing peers:"
./pigeon-cli peer remove @CHANGE_THIS_TO_BASE_32.ed25519
./pigeon-cli peer remove @CHANGE_THIS_TO_BASE_32.ed25519

echo "blocking peers:"
./pigeon-cli peer block @CHANGE_THIS_TO_BASE_32.ed25519
./pigeon-cli peer block @CHANGE_THIS_TO_BASE_32.ed25519
./pigeon-cli peer block @CHANGE_THIS_TO_BASE_32.ed25519

echo "listing all peers:"
./pigeon-cli peer all

echo "Making a new `scratch_pad` log entry"
./pigeon-cli draft create scratch_pad

echo "Appending values..."

echo "...string via pipe"

echo "my_value" | ./pigeon-cli draft append key1

echo "...string with no quotes"
./pigeon-cli draft append key2 my_value2

echo "...string with quotes"
./pigeon-cli draft append key3 "my_value3"

echo "...draft ID"
./pigeon-cli draft append key4 \%CHANGE_THIS_TO_BASE_32.sha256

echo "...blob"
./pigeon-cli draft append key5 \&CHANGE_THIS_TO_BASE_32.sha256

echo "...identity"
./pigeon-cli draft append key6 \@CHANGE_THIS_TO_BASE_32.ed25519

echo "== show draft"
./pigeon-cli draft show

echo "== sign (publish, save, commit, etc) draft"
./pigeon-cli draft sign

echo "=== add a second draft to the db"
./pigeon-cli draft create second_test

echo "=== append hello:'world' to draft:"
./pigeon-cli draft append hello "world"

echo "=== Sign draft #2"
./pigeon-cli draft sign

echo "=== Dump the bundle"
./pigeon-cli bundle create
cat pigeon.bundle
echo "=== end bundle dump"

echo "=== find a message"
./pigeon-cli message find (./pigeon-cli message last)

echo "== find all messages"
./pigeon-cli message find-all

echo "=== getting status:"
./pigeon-cli status
