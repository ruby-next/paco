# Documentation

## Paco::Combinators: Main methods

### Paco::Combinators.not_followed_by(parser)

Returns a parser that runs the passed `parser` without consuming the input, and returns `null` if the passed `parser` _does not match_ the input. Fails otherwise.

### Paco::Combinators.succeed(result)

Returns a parser that doesn't consume any input and always returns `result`.

### Paco::Combinators.failed(message)

Returns a parser that doesn't consume any input and always fails with passed `message`.

### Paco::Combinators.lookahead(parser)

Returns a parser that runs the passed `parser` without consuming the input, and returns empty string.

### Paco::Combinators.alt(*parsers)

Accepts one or more parsers, and returns a parser that returns the value of the first parser that succeeds, backtracking in between.

### Paco::Combinators.seq(*parsers)

Accepts one or more parsers, and returns a parser that expects them to match in order, returns an array of all their results.

### Paco::Combinators.seq_map(*parsers, &block)

Returns a parser that matches all `parsers` sequentially, and passes their results as an arguments to a `block`, and at the end returns its result.

### Paco::Combinators.many(parser)

Expects `parser` zero or more times, and returns an array of the results.

### Paco::Combinators.sep_by(parser, separator)

Returns a parser that expects **zero or more** matches for `parser`, separated by the parser `separator`. Returns an array of `parser` results.

```ruby
example = Paco::Combinators.sep_by(
  Paco::Combinators.digits,
  Paco::Combinators.string(",")
)
example.parse("1,1,2,3,5,8,13,21") #=> ["1", "1", "2", "3", "5", "8", "13", "21"]
```

### Paco::Combinators.sep_by_1(parser, separator)

Returns a parser that expects **one or more** matches for `parser`, separated by the parser `separator`. Returns an array of `parser` results.

### Paco::Combinators.wrap(before, after, parser)

Expects the parser `before` before `parser` and `after` after `parser. Returns the result of the parser.

### Paco::Combinators.optional(parser)

Returns parser that returns result of the passed `parser` or nil if `parser` fails.

### Paco::Combinators.lazy(desc = "", &block)

Accepts a block that returns a parser, which is evaluated the first time the parser is used. This is useful for referencing parsers that haven't yet been defined, and for implementing recursive parsers.

## Paco::Combinators: Text related methods

### Paco::Combinators.string(matcher)

Returns a parser that looks for a passed `matcher` string and returns its value on success.

### Paco::Combinators.satisfy(&block)

Returns a parser that returns a single character if passed block result is truthy:

```ruby
lower = Paco::Combinators.satisfy do |char|
  char == char.downcase
end

lower.parse("a") #=> "a"
lower.parse("P") #=> ParseError
```

### Paco::Combinators.take_while(&block)

Returns a parser that returns a string containing all the next characters that are truthy for the passed block.

Alias for `satisfy(&block).many`.

### Paco::Combinators.one_of(matcher)

Returns a parser that looks for exactly one character from passed `matcher`, and returns its value on success.

### Paco::Combinators.none_of(matcher)

Returns a parser that looks for exactly one character _NOT_ from passed `matcher`, and returns its value on success.

### Paco::Combinators.regexp(regexp, group: 0)

Returns a parser that looks for a match to the regexp and returns the entire text matched. The regexp will always match starting at the current parse location. When `group` is specified, it returns only the text in the specific regexp match group.

### Paco::Combinators.regexp_char(regexp)

Returns a parser that checks current character against the passed `regexp`.

### Paco::Combinators.any_char

Returns a parser that consumes and returns the next character of the input.

### Paco::Combinators.remainder

Returns a parser that consumes and returns the entire remainder of the input.

### Paco::Combinators.eof

Returns a parser that matches end of file and returns nil.

### Paco::Combinators.cr

Returns a parser that checks for the "carriage return" (`\r`) character.

An alias for `Paco::Combinators.string("\r")`

### Paco::Combinators.lf

Returns a parser that checks for the "line feed" (`\n`) character.

An alias for `Paco::Combinators.string("\n")`

### Paco::Combinators.crlf

Returns a parser that checks for the "carriage return" character followed by the "line feed" character (`\r\n`).

An alias for `Paco::Combinators.string("\r\n")`

### Paco::Combinators.newline

Returns a parser that will match any kind of line ending.

An alias for:

```ruby
Combinators.alt(
  Paco::Combinators.crlf, Paco::Combinators.lf, Paco::Combinators.cr
)
```

### Paco::Combinators.end_of_line

Returns a parser that will match any kind of line ending *including* end of file.

An alias for:

```ruby
Combinators.alt(
  Paco::Combinators.newline, Paco::Combinators.eof
)
```

### Paco::Combinators.letter

Alias for `Paco::Combinators.regexp(/[a-z]/i)`.

### Paco::Combinators.letters

Alias for `Paco::Combinators.regexp(/[a-z]+/i)`.

### Paco::Combinators.opt_letters

Alias for `Paco::Combinators.regexp(/[a-z]*/i)`.

### Paco::Combinators.digit

Alias for `Paco::Combinators.regexp(/[0-9]/)`.

### Paco::Combinators.digits

Alias for `Paco::Combinators.regexp(/[0-9]+/)`.

### Paco::Combinators.opt_digits

Alias for `Paco::Combinators.regexp(/[0-9]*/)`.

### Paco::Combinators.ws

Alias for `Paco::Combinators.regexp(/\s+/)`.

### Paco::Combinators.opt_ws

Alias for `Paco::Combinators.regexp(/\s*/)`.

### Paco::Combinators.spaced(parser)

Alias for `parser.trim(Paco::Combinators.opt_ws)`.

## Paco::Parser methods

### Paco::Parser#parse(input)

Applies `parser` on the provided string `input` and returns a parsed result or raises a `ParseError` exception.

```ruby
example = Paco::Combinators.string("Paco")

example.parse("Paco")
```

### Paco::Parser#failure(ctx)

Raises `ParseError`, used internally by `Paco`:

```ruby

def eof
  Parser.new("end of file") do |ctx, parser|
    parser.failure(ctx) unless ctx.eof?
    nil
  end
end
```

### Paco::Parser#or(other)

Returns a new parser which tries `parser`, and if it fails uses `other`.

```ruby
bool = Paco::Combinators.string("true").or Paco::Combinators.string("false")

bool.parse("true") #=> true
bool.parse("false") #=> false
```

### Paco::Parser#skip(other)

Expects `other` parser to follow `parser`, but returns only the value of `parser`.

```ruby
example = Paco::Combinators.any_char.skip(Paco::Combinators.opt_ws)

example.parse("P    ") #=> "P"
example.parse("a") #=> "a"
```

### Paco::Parser#next(other)

Expects `other` parser to follow `parser`, but returns only the value of `other` parser.

```ruby
example = Paco::Combinators.regexp(/[+ ]*/).next(Paco::Combinators.digits)

example.parse("42") #=> "42"
example.parse("+42") #=> "42"
example.parse(" + 42") #=> "42"
```

### Paco::Parser#fmap(other)

Transforms the output of `parser` with the given block.

```ruby
example = Paco::Combinators.regexp(/[0-9]+/)
  .fmap(&:to_i)
  .fmap { |num| num + 1 }

example.parse("9") #=>  10
```

### Paco::Parser#bind(other)

Returns a new parser which tries `parser`, and on success calls the `block` with the result of the parse, which is expected to return another parser, which will be tried next. This allows you to dynamically decide how to continue the parse.

```ruby
include Paco::Combinators

char_pairs = {"[" => "]", "(" => ")", "{" => "}", "<" => ">"}

array_of_strings = string("%").next(any_char).bind do |char|
  end_char = char_pairs[char] || char

  many(satisfy { |ch| ch != end_char }.skip(opt_ws)).skip(string(end_char))
end

array_of_strings.parse("%[a b c]") #=> ["a", "b", "c"]
array_of_strings.parse("%(a b c)") #=> ["a", "b", "c"]
array_of_strings.parse("%|a b c|") #=> ["a", "b", "c"]
```

### Paco::Parser#many

Expects `parser` zero or more times, and returns an array of the results.

### Paco::Parser#times(min, max = nil)

Returns a parser that runs `parser` between `min` and `max` times, and returns an array of the results. When `max` is not specified, `max` = `min`.

### Paco::Parser#at_least(num)

Returns a parser that runs `parser` at least `num` times, and returns an array of the results.

### Paco::Parser#at_most(num)

Returns a parser that runs `parser` at most `num` times, and returns an array of the results.

### Paco::Parser#result(value)

Returns a new parser with the same behavior, but which returns passed `value`.

### Paco::Parser#fallback(value)

Returns a new parser which tries `parser` and, if it fails, returns `value` without consuming any input.

```ruby
example = Paco::Combinators.digit.fallback("0")

example.parse("4") #=> "4"
example.parse("") #=> "0"
```

### Paco::Parser#trim(other)

Expects `other` parser before and after `parser`. Returns the result of the parser.

### Paco::Parser#wrap(before, after)

Expects the parser `before` before `parser` and `after` after `parser. Returns the result of the parser.

### Paco::Parser#not_followed_by(other)

Returns a parser that runs the passed `other` parser without consuming the input, and returns result of the `parser` if the passed one _does not match_ the input. Fails otherwise.

### Paco::Parser#join(separator = "")

Returns a parser that runs `parser` and concatenate it results with the `separator`.

### Paco::Parser#
