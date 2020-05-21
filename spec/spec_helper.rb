require "pry"
require "simplecov"
NORMAL_PATH = "./spec/fixtures/normal/"
HAS_BLOB_PATH = "./spec/fixtures/has_blobs"
BLOCKED_PEER_FIXTURE_PATH = "./spec/fixtures/x"

def regenerate_fixture_normal_path(db)
  db.add_message("unit_test1", { "foo" => "bar" })
  db.add_message("unit_test2", { "bar" => "baz" })
  db.add_message("unit_test3", { "cats" => "meow" })
  db.export_bundle(NORMAL_PATH)
  full_path = NORMAL_PATH + Pigeon::MESSAGE_FILE
  bundle = File.read(full_path)
  tokens = Pigeon::Lexer.tokenize(bundle)
  puts "=== CHANGE THE TOP VALUE TO THIS ==="
  puts "EXPECTED_TOKENS1 = #{tokens.inspect}"
end

def regenerate_fixture_has_blobs(db)
  db.reset_database
  blobs = %w(./a.gif ./b.gif ./c.gif)
    .map { |x| File.read(x) }
    .map { |x| db.add_blob(x) }
    .map { |x| db.add_message("example", { "file_name" => x }) }
  db.export_bundle(HAS_BLOB_PATH)
end

def regenerate_fixture_x(db)
  db.reset_database
  db.add_message("nonsense", { "example" => "Just block me" })
  db.export_bundle(BLOCKED_PEER_FIXTURE_PATH)
end

SimpleCov.start
require_relative File.join("..", "lib", "pigeon")
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.disable_monkey_patching!
  config.order = :random
end
