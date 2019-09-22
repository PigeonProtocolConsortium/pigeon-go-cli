require "pry"
require "simplecov"
SimpleCov.start
require_relative File.join("..", "dist", "pigeon")
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.disable_monkey_patching!
  config.order = :random
end