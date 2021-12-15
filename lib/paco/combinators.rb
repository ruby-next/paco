# frozen_string_literal: true

require "paco/combinators/char"
require "paco/memoizer"

module Paco
  module Combinators
    def self.extended(base)
      base.extend Char
    end

    def self.included(base)
      base.include Char
    end

    extend self

    # Returns a parser that runs the passed `parser` without consuming the input, and
    # returns `null` if the passed `parser` _does not match_ the input. Fails otherwise.
    # @param [Paco::Parser] parser
    # @return [Paco::Parser]
    def not_followed_by(parser)
      Parser.new("not #{parser.desc}") do |ctx, pars|
        start_pos = ctx.pos
        begin
          parser._parse(ctx)
        rescue ParseError
          ctx.pos = start_pos
          nil
        else
          pars.failure(ctx)
        end
      end
    end

    # Returns a parser that doesn't consume any input and always returns `result`.
    # @return [Paco::Parser]
    def succeed(result)
      Parser.new("succeed(#{result})") { result }
    end

    # Returns a parser that doesn't consume any input and always fails with passed `message`.
    # @param [String] message
    # @return [Paco::Parser]
    def failed(message)
      Parser.new(message) { |ctx, parser| parser.failure(ctx) }
    end

    # Returns a parser that runs the passed `parser` without consuming the input,
    # and returns empty string.
    # @param [Paco::Parser] parser
    # @return [Paco::Parser]
    def lookahead(parser)
      Parser.new("lookahead(#{parser.desc})") do |ctx|
        start_pos = ctx.pos
        parser._parse(ctx)
        ctx.pos = start_pos
        ""
      end
    end

    # Accepts any number of parsers, and returns a parser that returns the value of the first parser that succeeds, backtracking in between.
    # @param [Array<Paco::Parser>] parsers
    # @return [Paco::Parser]
    def alt(*parsers)
      raise ArgumentError, "no parsers specified" if parsers.empty?

      Parser.new("alt(#{parsers.map(&:desc).join(", ")})") do |ctx|
        result = nil
        last_error = nil
        start_pos = ctx.pos
        parsers.each do |pars|
          break result = {value: pars._parse(ctx)}
        rescue ParseError => e
          last_error = e
          ctx.pos = start_pos
          next
        end
        raise last_error unless result
        result[:value]
      end
    end

    # Accepts one or more parsers, and returns a parser that expects them
    # to match in order, returns an array of all their results.
    # @param [Array<Paco::Parser>] parsers
    # @return [Paco::Parser]
    def seq(*parsers)
      raise ArgumentError, "no parsers specified" if parsers.empty?

      Parser.new("seq(#{parsers.map(&:desc).join(", ")})") do |ctx|
        parsers.map { |parser| parser._parse(ctx) }
      end
    end

    # Returns a parser that matches all `parsers` sequentially, and passes
    # their results as an arguments to a `block`, and at the end returns its result.
    # @param [Array<Paco::Parser>] parsers
    # @return [Paco::Parser]
    def seq_map(*parsers, &block)
      raise ArgumentError, "no parsers specified" if parsers.empty?

      seq(*parsers).fmap do |results|
        block.call(*results)
      end
    end

    # Accepts a block that returns a parser, which is evaluated the first time the parser is used.
    # This is useful for referencing parsers that haven't yet been defined, and for implementing recursive parsers.
    # @return [Paco::Parser]
    def lazy(desc = "", &block)
      Parser.new(desc) { |ctx| block.call._parse(ctx) }
    end

    # Returns a parser that expects zero or more matches for `parser`,
    # separated by the parser `separator`. Returns an array of `parser` results.
    # @param [Paco::Parser] parser
    # @param [Paco::Parser] separator
    # @return [Paco::Parser]
    def sep_by(parser, separator)
      alt(sep_by_1(parser, separator), succeed([]))
        .with_desc("sep_by(#{parser.desc}, #{separator.desc})")
    end

    # Returns a parser that expects one or more matches for `parser`,
    # separated by the parser `separator`. Returns an array of `parser` results.
    # @param [Paco::Parser] parser
    # @param [Paco::Parser] separator
    # @return [Paco::Parser]
    def sep_by_1(parser, separator)
      seq_map(parser, many(separator.next(parser))) { |first, arr| [first] + arr }
        .with_desc("sep_by_1(#{parser.desc}, #{separator.desc})")
    end

    # Expects the parser `before` before `parser` and `after` after `parser. Returns the result of the parser.
    # @param [Paco::Parser] before
    # @param [Paco::Parser] after
    # @param [Paco::Parser] parser
    # @return [Paco::Parser]
    def wrap(before, after, parser)
      before.next(parser).skip(after)
    end

    # Expects `parser` zero or more times, and returns an array of the results.
    # @param [Paco::Parser] parser
    # @return [Paco::Parser]
    def many(parser)
      Parser.new("many(#{parser.desc})") do |ctx|
        results = []
        loop do
          results << parser._parse(ctx)
        rescue ParseError
          break
        end
        results
      end
    end

    # Returns parser that returns result of the passed `parser` or nil if `parser` fails.
    # @param [Paco::Parser] parser
    # @return [Paco::Parser]
    def optional(parser)
      alt(parser, succeed(nil))
    end

    # Helper used for memoization
    def memoize(&block)
      Memoizer.memoize(block.source_location, &block)
    end
  end
end
