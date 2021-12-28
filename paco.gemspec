# frozen_string_literal: true

require_relative "lib/paco/version"

Gem::Specification.new do |spec|
  spec.name = "paco"
  spec.version = Paco::VERSION
  spec.authors = ["Svyatoslav Kryukov"]
  spec.email = ["s.g.kryukov@yandex.ru"]

  spec.summary = "Parser combinator library"
  spec.description = "Paco is a parser combinator library."
  spec.homepage = "https://github.com/skryukov/paco"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.2.0"

  spec.metadata = {
    "bug_tracker_uri" => "#{spec.homepage}/issues",
    "changelog_uri" => "#{spec.homepage}/blob/master/CHANGELOG.md",
    "documentation_uri" => "#{spec.homepage}/blob/master/README.md",
    "homepage_uri" => spec.homepage,
    "source_code_uri" => spec.homepage
  }

  spec.files = Dir.glob("lib/**/*") + Dir.glob("lib/.rbnext/**/*") + %w[README.md LICENSE.txt CHANGELOG.md]

  spec.require_paths = ["lib"]

  spec.add_dependency "ruby-next-core", ">= 0.13.0"
end
