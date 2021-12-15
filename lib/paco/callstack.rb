# frozen_string_literal: true

module Paco
  class Callstack
    attr_reader :stack

    def initialize
      @stack = []
      @depth = 0
    end

    def failure(**params)
      @depth -= 1
      @stack << params.merge(status: :failure, depth: @depth)
    end

    def start(**params)
      @depth += 1
      @stack << params.merge(status: :start, depth: @depth)
    end

    def success(**params)
      @depth -= 1
      @stack << params.merge(status: :success, depth: @depth)
    end
  end
end
