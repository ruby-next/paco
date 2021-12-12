# frozen_string_literal: true

require "paco/version"
require "paco/parse_error"
require "paco/context"
require "paco/parser"
require "paco/combinators"

module Paco
  def self.extended(base)
    base.extend Combinators
  end

  def self.included(base)
    base.include Combinators
  end
end
