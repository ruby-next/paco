# frozen_string_literal: true

require "memo_wise"

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
