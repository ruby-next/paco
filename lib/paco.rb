# frozen_string_literal: true

if RUBY_VERSION < "2.6.0"
  $LOAD_PATH.unshift File.expand_path("./.rbnext", __dir__)
end

require "paco/version"
require "paco/parse_error"
require "paco/context"
require "paco/parser"

module Paco
  def self.extended(base)
    base.extend Combinators
  end

  def self.included(base)
    base.include Combinators
  end
end
