# frozen_string_literal: true

require "paco/combinators"

module Paco
  class Parser
    attr_reader :desc

    # @param [String] desc
    def initialize(desc = "", &block)
      @desc = desc
      @block = block
    end

    # @param [String] desc
    # @return [Paco::Parser]
    def with_desc(desc)
      @desc = desc
      self
    end

    # @param [String, Paco::Context] input
    # @param [true, false] with_callstack
    def parse(input, with_callstack: false)
      ctx = input.is_a?(Context) ? input : Context.new(input, with_callstack: with_callstack)
      catch :paco_parse_error do
        return skip(Paco::Combinators.eof)._parse(ctx)
      end
      raise ParseError.new(ctx, desc), "", []
    end

    # @param [Paco::Context] ctx
    def _parse(ctx)
      ctx.start_parse(self)
      res = @block.call(ctx, self)
      ctx.success_parse(res, self)
      res
    end

    # Raises ParseError
    # @param [Paco::Context] ctx
    # @raise [Paco::ParseError]
    def failure(ctx)
      ctx.failure_parse(self)
      # raise ParseError.new(ctx, desc), "", []
      throw :paco_parse_error
    end

    # Returns a new parser which tries `parser`, and if it fails uses `other`.
    # @param [Paco::Parser] other
    # @return [Paco::Parser]
    def or(other)
      Parser.new("or(#{desc}, #{other.desc})") do |ctx|
        res = catch :paco_parse_error do
          {value: _parse(ctx)}
        end
        next res[:value] unless res.nil?
        other._parse(ctx)
      end
    end
    alias_method :|, :or

    # Expects `other` parser to follow `parser`, but returns only the value of `parser`.
    # @param [Poco::Parser] other
    # @return [Paco::Parser]
    def skip(other)
      Paco::Combinators.seq(self, other).fmap { |results| results[0] }.with_desc("#{desc}.skip(#{other.desc})")
    end
    alias_method :<, :skip

    # Expects `other` parser to follow `parser`, but returns only the value of `other` parser.
    # @param [Poco::Parser] other
    # @return [Paco::Parser]
    def next(other)
      Paco::Combinators.seq(self, other).fmap { |results| results[1] }
        .with_desc("#{desc}.next(#{other.desc})")
    end
    alias_method :>, :next

    # Transforms the output of `parser` with the given block.
    # @return [Paco::Parser]
    def fmap(&block)
      Parser.new("#{desc}.fmap") do |ctx|
        block.call(_parse(ctx))
      end
    end

    # Returns a new parser which tries `parser`, and on success
    # calls the `block` with the result of the parse, which is expected
    # to return another parser, which will be tried next. This allows you
    # to dynamically decide how to continue the parse, which is impossible
    # with the other Paco::Combinators.
    # @return [Paco::Parser]
    def bind(&block)
      Parser.new("#{desc}.bind") do |ctx|
        block.call(_parse(ctx))._parse(ctx)
      end
    end
    alias_method :chain, :bind

    # Expects `parser` zero or more times, and returns an array of the results.
    # @return [Paco::Parser]
    def many
      Paco::Combinators.many(self)
    end

    # Returns a new parser with the same behavior, but which returns passed `value`.
    # @return [Paco::Parser]
    def result(value)
      fmap { value }
    end

    # Returns a new parser which tries `parser` and, if it fails, returns `value` without consuming any input.
    # @return [Paco::Parser]
    def fallback(value)
      self.or(Paco::Combinators.succeed(value))
    end

    # Expects `other` parser before and after `parser`, and returns the result of the parser.
    # @param [Paco::Parser] other
    # @return [Paco::Parser]
    def trim(other)
      other.next(self).skip(other)
    end

    # Expects the parser `before` before `parser` and `after` after `parser. Returns the result of the parser.
    # @param [Paco::Parser] before
    # @param [Paco::Parser] after
    # @return [Paco::Parser]
    def wrap(before, after)
      Paco::Combinators.wrap(before, after, self)
    end

    # Returns a parser that runs passed `other` parser without consuming the input, and
    # returns result of the `parser` if the passed one _does not match_ the input. Fails otherwise.
    # @param [Paco::Parser] other
    # @return [Paco::Parser]
    def not_followed_by(other)
      skip(Paco::Combinators.not_followed_by(other))
    end

    # Returns a parser that runs `parser` and concatenate it results with the `separator`.
    # @param [String] separator
    # @return [Paco::Parser]
    def join(separator = "")
      fmap { |result| result.join(separator) }
    end

    # Returns a parser that runs `parser` between `min` and `max` times,
    # and returns an array of the results. When `max` is not specified, `max` = `min`.
    # @param [Integer] min
    # @param [Integer] max
    # @return [Paco::Parser]
    def times(min, max = nil)
      max ||= min
      if min < 0 || max < min
        raise ArgumentError, "invalid attributes: min `#{min}`, max `#{max}`"
      end

      Parser.new("#{desc}.times(#{min}, #{max})") do |ctx|
        results = min.times.map { _parse(ctx) }

        catch :paco_parse_error do
          (max - min).times.each do
            results << _parse(ctx)
          end
        end

        results
      end
    end

    # Returns a parser that runs `parser` at least `num` times,
    # and returns an array of the results.
    def at_least(num)
      Paco::Combinators.seq(times(num), many) do |head, rest|
        head + rest
      end
    end

    # Returns a parser that runs `parser` at most `num` times,
    # and returns an array of the results.
    def at_most(num)
      times(0, num)
    end
  end
end
