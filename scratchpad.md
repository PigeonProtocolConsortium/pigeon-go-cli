BEFORE DELETING CONSTANTS:
==========================
rspec ./spec/pigeon/kitchen_sink_spec.rb:4 # Kitch sink spec does everything
rspec ./spec/pigeon/storage_spec.rb:15 # Pigeon::Storage deletes a config
rspec ./spec/pigeon/storage_spec.rb:34 # Pigeon::Storage manages blobs
rspec ./spec/pigeon/storage_spec.rb:41 # Pigeon::Storage manages peers
rspec ./spec/pigeon/storage_spec.rb:26 # Pigeon::Storage manages configs
rspec ./spec/pigeon/key_pair_spec.rb:36 # Pigeon::KeyPair saves to disk

