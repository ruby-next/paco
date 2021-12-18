# frozen_string_literal: true
module Paco
  class Error < StandardError; end

  class ParseError < Error
    attr_reader :ctx, :pos, :expected

    # @param [Paco::Context] ctx
    def initialize(ctx, expected)
      @ctx = ctx
      @pos = ctx.pos
      @expected = expected
    end

    def callstack
      ctx.callstack
    end

    def message
      index = ctx.index(pos)
      <<~MSG
        \nParsing error
        line #{index.line}, column #{index.column}:
        unexpected #{ctx.eof? ? "end of file" : ctx.input[pos].inspect}
        expecting #{expected}
      MSG
    end
  end
end
