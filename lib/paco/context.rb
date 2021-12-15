# frozen_string_literal: true

require "paco/callstack"

module Paco
  class Context
    attr_reader :input, :last_pos, :callstack
    attr_accessor :pos

    def initialize(input, pos: 0, with_callstack: false)
      @input = input
      @pos = pos
      @callstack = Callstack.new if with_callstack
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

    # @param [Paco::Parser] parser
    def failure_parse(parser)
      @callstack&.failure(pos: pos, parser: parser.desc)
    end

    # @param [Paco::Parser] parser
    def start_parse(parser)
      @callstack&.start(pos: pos, parser: parser.desc)
    end

    # @param [Object] result
    # @param [Paco::Parser] parser
    def success_parse(result, parser)
      @callstack&.success(pos: pos, result: result, parser: parser.desc)
    end
  end
end
