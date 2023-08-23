# frozen_string_literal: true

if ENV["EOL"] != "true"
  require "simplecov"

  SimpleCov.start do
    add_filter "/spec/"
    enable_coverage :branch
  end
end

require "backports/2.5" if ENV["EOL"] == "true"

require "ruby-next/language/runtime" unless ENV["CI"]

require "paco"
require "paco/rspec"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.order = :random
  Kernel.srand config.seed

  config.include Paco::Combinators, :include_combinators
end
