#!/usr/bin/env fish

# This is a script that
# run all CLI commands at once
# for quick QA.

echo "Deleting old pigeon configs"
rm -rf .pigeon/
echo "OK"

echo "Creating new config:"
./pigeon-cli identity new
./pigeon-cli identity show

echo "Creating kitty cat blobs:"
cat scratchpad.jpg | ./pigeon-cli blob set

echo "Adding peers:"
./pigeon-cli peer add @_TlC2z3FT4fimecC4eytrBhOwhLUZsVBZEZriBO9cWs=.ed25519
./pigeon-cli peer add @28FyT7evjcYrrwngr8G2V1HZ0ODK0VPsFctDEZwfZJc=.ed25519
./pigeon-cli peer add @ExA5Fmld-vMDjROfN30G5pmSp_261QILFP3qe64iDn8=.ed25519
./pigeon-cli peer add @galdahnB3L2DE2cTU0Me54IpIUKVEgKmBwvZVtWJccg=.ed25519
./pigeon-cli peer add @I6cN_IE9iPmH05xXnlI_WyLqnrAoKv1plUKWfiGSSK4=.ed25519
./pigeon-cli peer add @JnCKDs5tIzY9OF--GFT94Qj5jHtK7lTxqCt1tmPcwjM=.ed25519
./pigeon-cli peer add @q-_9BTnTThvW2ZGkmy8D3j-hW9ON2PNa3nwbCQgRw-g=.ed25519
./pigeon-cli peer add @VIim19-PzaavRICicQg4c4z08SoWTa1tr2e-kfhmm0Y=.ed25519

echo "removing peers:"
./pigeon-cli peer remove @mYWRsosFtoxvn3GURmmE0FVtOWPcYv4ovXIAqy49sH4=.ed25519
./pigeon-cli peer remove @Nf7ZU9fLwukgfRfCunDtfjXRlhitiR-DcTmlNhB8lwk=.ed25519

echo "blocking peers:"
./pigeon-cli peer block @q-_9BTnTThvW2ZGkmy8D3j-hW9ON2PNa3nwbCQgRw-g=.ed25519
./pigeon-cli peer block @VIim19-PzaavRICicQg4c4z08SoWTa1tr2e-kfhmm0Y=.ed25519
./pigeon-cli peer block @VMSPmcYm1qXJy27V_MH1HGA7Mr3sOMikKOwfxT26hQg=.ed25519

echo "listing all peers:"
./pigeon-cli peer all

echo "Making a new `scratch_pad` log entry"
./pigeon-cli message create scratch_pad

echo "Appending values..."

echo "...string via pipe"
echo "my_value" | ./pigeon-cli message append key1

echo "...string with no quotes"
./pigeon-cli message append key2 my_value2

echo "...string with quotes"
./pigeon-cli message append key3 "my_value3"

echo "...message ID"
./pigeon-cli message append key4 \%jvKh9yoiEJaePzoWCF1nnqpIlPgTk9FHEtqczQbvzGM=.sha256

echo "...blob"
./pigeon-cli message append key5 \&29f3933302c49c60841d7620886ce54afc68630242aee6ff683926d2465e6ca3.sha256

echo "...identity"
./pigeon-cli message append key6 \@galdahnB3L2DE2cTU0Me54IpIUKVEgKmBwvZVtWJccg=.ed25519

echo "== show draft message"
./pigeon-cli message show

echo "== sign (publish, save, commit, etc) draft message"
./pigeon-cli message sign

echo "=== add a second message to the db"
./pigeon-cli message create second_test
echo "=== append hello:'world' to message:"
./pigeon-cli message append hello "world"
./pigeon-cli message sign
echo "=== Sign message #2"
./pigeon-cli message show

echo "=== getting status:"
./pigeon-cli status
