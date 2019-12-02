require "spec_helper"

RSpec.describe "Kitch sink spec" do
  it "does everything" do
    kp = Pigeon::KeyPair.new()
    kp.save!
    Pigeon::KeyPair.current.public_key
    # ./pigeon-cli identity new
    # ./pigeon-cli identity show
    # cat scratchpad.jpg | ./pigeon-cli blob set
    # ./pigeon-cli peer add @_TlC2z3FT4fimecC4eytrBhOwhLUZsVBZEZriBO9cWs=.ed25519
    # ./pigeon-cli peer add @28FyT7evjcYrrwngr8G2V1HZ0ODK0VPsFctDEZwfZJc=.ed25519
    # ./pigeon-cli peer remove @mYWRsosFtoxvn3GURmmE0FVtOWPcYv4ovXIAqy49sH4=.ed25519
    # ./pigeon-cli peer remove @Nf7ZU9fLwukgfRfCunDtfjXRlhitiR-DcTmlNhB8lwk=.ed25519
    # ./pigeon-cli peer block @q-_9BTnTThvW2ZGkmy8D3j-hW9ON2PNa3nwbCQgRw-g=.ed25519
    # ./pigeon-cli peer block @VIim19-PzaavRICicQg4c4z08SoWTa1tr2e-kfhmm0Y=.ed25519
    # ./pigeon-cli peer all
    # ./pigeon-cli message create scratch_pad
    # echo "my_value" | ./pigeon-cli message append key1
    # ./pigeon-cli message append key2 my_value2
    # ./pigeon-cli message append key3 "my_value3"
    # ./pigeon-cli message append key4 \%jvKh9yoiEJaePzoWCF1nnqpIlPgTk9FHEtqczQbvzGM=.sha256
    # ./pigeon-cli message append key5 \&29f3933302c49c60841d7620886ce54afc68630242aee6ff683926d2465e6ca3.sha256
    # ./pigeon-cli message append key6 \@galdahnB3L2DE2cTU0Me54IpIUKVEgKmBwvZVtWJccg=.ed25519
    # ./pigeon-cli message show
    # ./pigeon-cli message sign
    # ./pigeon-cli message create second_test
    # ./pigeon-cli message append hello "world"
    # ./pigeon-cli message sign
    # ./pigeon-cli status
  end
end
