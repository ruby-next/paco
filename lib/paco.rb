# frozen_string_literal: true

require "ruby-next/language/setup"
RubyNext::Language.setup_gem_load_path(transpile: true)

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
