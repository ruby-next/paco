# frozen_string_literal: true
module Paco
  class Context
    attr_reader :input, :last_pos, :pos

    def pos=(np)
      # TODO: is that needed?
      @last_pos = @pos
      @pos = np
    end

    def initialize(input, pos = 0)
      @input = input
      @pos = pos
    end

    def read(n)
      input[pos, n]
    end

    def read_all
      input[pos..-1]
    end

    def eof?
      pos >= input.length
    end

    def index(from = nil)
      from ||= pos
      lines = input[0..from].lines

      {
        line: lines.length,
        column: lines[-1]&.length || 0,
        pos: from
      }
    end
  end
end
