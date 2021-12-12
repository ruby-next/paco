# frozen_string_literal: true
module Paco
  class Error < StandardError; end

  class ParseError < Error
    # @param [Paco::Context] ctx
    def initialize(ctx, expected)
      @ctx = ctx
      @pos = ctx.pos
      @expected = expected

      # TODO: make this possible to show every parsing message? or last n?
      # puts ""
      # puts "#{ctx.pos}/#{ctx.input.length}: #{ctx.input[ctx.last_pos..ctx.pos]}"
      # puts "expected: #{expected}"
      # puts ""
    end

    def message
      index = @ctx.index(@pos)
      <<~MSG
        Parsing error
        line #{index[:line]}, column #{index[:column]}:
        unexpected #{@ctx.input[@pos] || "end of file"}
        expecting #{@expected}
      MSG
    end
  end
end
