#!/bin/sh

# This is a script that
# run all CLI commands at once
# for quick QA.

echo "Deleting old pigeon configs"
rm -f db.pigeon
rm -f pigeon.bundle
echo "OK"

echo "Creating new config:"
pigeon-cli identity new
pigeon-cli identity show

echo "Creating kitty cat blobs:"
cat scratchpad.jpg | pigeon-cli blob set

echo "Adding peers:"

pigeon-cli peer add @ZMS36YMSTYC19EX8AS07G0XAYEK643YM6SB6NYWATMEBSS92BVH0.ed25519
pigeon-cli peer add @3EEQ2ETD23DYS1SWBQ373796TR8W865EBWHYAFPBZ8YA2FRCR0YG.ed25519
pigeon-cli peer add @Y9DG9GZMWJPRW47D0MGMTJNV0PQPFANW7Q5J05PXT0ZNY9PMCZGG.ed25519
pigeon-cli peer add @WPFKCW2B9SDKBY7NNTVEV7TBZVTEH6J21NXNHQR3006GT1H8PEW0.ed25519
pigeon-cli peer add @C1KG390SFSZ49P824GNCTP7YF8ZM2SCFGGFBNHBKEKZYGPYTZYX0.ed25519
pigeon-cli peer add @W1FJYN9ZKZHMBTW8Q8DCVB8YVE5Y7Z896BSM85XEFKXZWPG70W70.ed25519
pigeon-cli peer add @X5HCRRVH33J0EDJ42JJ193GVA2KDQ9ZW0RQ8RM9MVVPQVXQQC100.ed25519
pigeon-cli peer add @0Y82485FV56XRBZYT8DRRYPTE36J8NRN5979NE8EXNRMS4JVQMSG.ed25519

echo "removing peers:"
pigeon-cli peer remove @G28JPBYGNCPE19C32083CDGA0KBKVF5HFJPPDEC8J7CMR3CCBCC0.ed25519
pigeon-cli peer remove @YWK61TMCZS4WP0R9R3MKKF8HXVJCPTHMXY3NAQH5CQZVCSBRC4V0.ed25519

echo "blocking peers:"
pigeon-cli peer block @5NDF5NSJZCKDGJ5C5EXN4Q4NERXA8QTK3AKJTC9Y5E4K3J42H9E0.ed25519
pigeon-cli peer block @4MAA3HFRDHFK3H6EEDGE4DTAPP2T7TP2VD8G1X9AHDVXX7AMPA7G.ed25519
pigeon-cli peer block @41FNE08J5XK9GEV1BTEPT15WW1KDK5XCC8SMM62MQNYZ0785NJ80.ed25519

echo "listing all peers:"
pigeon-cli peer all

echo "Making a new 'scratch_pad' log entry"
pigeon-cli draft create scratch_pad

echo "Appending values..."

echo "...string via pipe"

echo "my_value" | pigeon-cli draft append key1

echo "...string with no quotes"
pigeon-cli draft append key2 my_value2

echo "...string with quotes"
pigeon-cli draft append key3 "my_value3"

echo "...draft ID"
pigeon-cli draft append key4 \%4Q7K6A1RW3XEHWFKWTN8SP2M0Q0PXSWPBCFVCZFGM3TAKM6G34SG.sha256

echo "...blob"
pigeon-cli draft append key5 \&Y2WZTXD32DNNVPPWVRZ15G2NKTPJTQ6BDW4M14D3NJ38NV3064D0.sha256

echo "...identity"
pigeon-cli draft append key6 \@VTE8VPT2S6CM50C2VBPGDHZAP7BWKGZXBVVX0ZPPMDRQ05FV8G80.ed25519

echo "== show draft"
pigeon-cli draft show

echo "== sign (publish, save, commit, etc) draft"
pigeon-cli draft sign

echo "=== add a second draft to the db"
pigeon-cli draft create second_test

echo "=== append hello:'world' to draft:"
pigeon-cli draft append hello "world"

echo "=== Sign draft #2"
pigeon-cli draft sign

echo "=== Dump the bundle"
pigeon-cli bundle create
cat pigeon.bundle
echo "=== end bundle dump. Ingesting bundle..."
pigeon-cli bundle ingest pigeon.bundle

echo "=== find a message"
pigeon-cli message find $(pigeon-cli message last)

echo "== find all messages"
pigeon-cli message find-all

echo "=== getting status:"
pigeon-cli status
