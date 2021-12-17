# frozen_string_literal: true

module Paco
  module Combinators
    module Char
      prepend MemoWise

      # Returns a parser that returns a single character if passed block result is truthy:
      #
      # @example
      # lower = Combinators.satisfy do |char|
      #   char == char.downcase
      # end
      #
      # lower.parse("a") #=> "a"
      # lower.parse("P") #=> ParseError
      #
      # @param [String] desc optional description for the parser
      # @param [Proc] block proc with one argument – a next char of the input
      # @return [Paco::Parser]
      def satisfy(desc = "", &block)
        Parser.new(desc) do |ctx, parser|
          parser.failure(ctx) if ctx.eof?

          char = ctx.read(1)
          parser.failure(ctx) unless block.call(char)

          ctx.pos += 1
          char
        end
      end

      # Returns a parser that looks for a passed `matcher` string and returns its value on success.
      # @param [String] matcher
      # @return [Paco::Parser]
      def string(matcher)
        Parser.new("string(#{matcher.inspect})") do |ctx, parser|
          src = ctx.read(matcher.length)
          parser.failure(ctx) if src != matcher

          ctx.pos += matcher.length
          src
        end
      end

      # Returns a parser that looks for a match to the regexp and returns the entire text matched.
      # The regexp will always match starting at the current parse location.
      # When `group` is specified, it returns only the text in the specific regexp match group.
      # @param [Regexp] regexp
      # @return [Paco::Parser]
      # @param [Integer] group
      def regexp(regexp, group: 0)
        anchored_regexp = Regexp.new("\\A(?:#{regexp.source})", regexp.options)
        Parser.new("regexp(#{regexp.inspect})") do |ctx, parser|
          match = anchored_regexp.match(ctx.read_all)
          parser.failure(ctx) if match.nil?

          ctx.pos += match[0].length
          match[group]
        end
      end

      # Returns a parser that checks current character against the passed `regexp`
      # @param [Regexp] regexp
      # @return [Paco::Parser]
      def regexp_char(regexp)
        satisfy("regexp_char(#{regexp.inspect})") { |char| regexp.match?(char) }
      end

      # Returns a parser that looks for exactly one character from passed
      # `matcher`, and returns its value on success.
      # @param [String, Array<String>] matcher
      # @return [Paco::Parser]
      def one_of(matcher)
        satisfy("one_of(#{matcher})") { |char| matcher.include?(char) }
      end

      # Returns a parser that looks for exactly one character _NOT_ from passed
      # `matcher`, and returns its value on success.
      # @param [String, Array<String>] matcher
      # @return [Paco::Parser]
      def none_of(matcher)
        satisfy("none_of(#{matcher})") { |char| !matcher.include?(char) }
      end

      # Returns a parser that consumes and returns the next character of the input.
      # @return [Paco::Parser]
      def any_char
        satisfy("any_char") { |ch| ch.length > 0 }
      end
      memo_wise :any_char

      # Returns a parser that consumes and returns the entire remainder of the input.
      # @return [Paco::Parser]
      def remainder
        Parser.new("remainder") do |ctx, parser|
          result = ctx.read_all
          ctx.pos += result.length
          result
        end
      end
      memo_wise :remainder

      # Returns a parser that returns a string containing all the next
      # characters that are truthy for the passed block.
      # @param [Proc] block proc with one argument – a next char of the input
      # @return [Paco::Parser]
      def take_while(&block)
        satisfy(&block).many.join
      end

      # Returns a parser that matches end of file and returns nil.
      # @return [Paco::Parser]
      def eof
        Parser.new("end of file") do |ctx, parser|
          parser.failure(ctx) unless ctx.eof?
          nil
        end
      end
      memo_wise :eof

      # Returns a parser that checks for the "carriage return" (`\r`) character.
      # @return [Paco::Parser]
      def cr
        string("\r")
      end
      memo_wise :cr

      # Returns a parser that checks for the "line feed" (`\n`) character.
      # @return [Paco::Parser]
      def lf
        string("\n")
      end
      memo_wise :lf

      # Returns a parser that checks for the "carriage return" character followed by the "line feed" character (`\r\n`).
      # @return [Paco::Parser]
      def crlf
        string("\r\n")
      end
      memo_wise :crlf

      # Returns a parser that will match any kind of line ending.
      # @return [Paco::Parser]
      def newline
        alt(crlf, lf, cr)
      end
      memo_wise :newline

      # Returns a parser that will match any kind of line ending *including* end of file.
      # @return [Paco::Parser]
      def end_of_line
        alt(newline, eof)
      end
      memo_wise :end_of_line

      # Alias for `Paco::Combinators.regexp_char(/[a-z]/i)`.
      # @return [Paco::Parser]
      def letter
        regexp_char(/[a-z]/i)
      end
      memo_wise :letter

      # Alias for `Paco::Combinators.regexp(/[a-z]+/i)`.
      # @return [Paco::Parser]
      def letters
        regexp(/[a-z]+/i)
      end
      memo_wise :letters

      # Alias for `Paco::Combinators.regexp(/[a-z]*/i)`.
      # @return [Paco::Parser]
      def opt_letters
        regexp(/[a-z]*/i)
      end
      memo_wise :opt_letters

      # Alias for `Paco::Combinators.regexp_char(/[0-9]/)`.
      # @return [Paco::Parser]
      def digit
        regexp_char(/[0-9]/)
      end
      memo_wise :digit

      # Alias for `Paco::Combinators.regexp(/[0-9]+/)`.
      # @return [Paco::Parser]
      def digits
        regexp(/[0-9]+/)
      end
      memo_wise :digits

      # Alias for `Paco::Combinators.regexp(/[0-9]*/)`.
      # @return [Paco::Parser]
      def opt_digits
        regexp(/[0-9]*/)
      end
      memo_wise :opt_digits

      # Alias for `Paco::Combinators.regexp(/\s+/)`.
      # @return [Paco::Parser]
      def ws
        regexp(/\s+/)
      end
      memo_wise :ws

      # Alias for `Paco::Combinators.regexp(/\s*/)`.
      # @return [Paco::Parser]
      def opt_ws
        regexp(/\s*/)
      end
      memo_wise :opt_ws

      # Alias for `parser.trim(Paco::Combinators.opt_ws)`.
      # @param [Paco::Parser] parser
      # @return [Paco::Parser]
      def spaced(parser)
        parser.trim(opt_ws)
      end
    end
  end
end
