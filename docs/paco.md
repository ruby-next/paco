# Documentation

## Table of contents

- [Usage](#usage)
- [Paco::Combinators: Main methods](#pacocombinators-main-methods)
- [Paco::Combinators: Text related methods](#pacocombinators-text-related-methods)
- [Paco::Parser methods](#pacoparser-methods)
- [Debugging](#debugging)
- [Test helpers](#test-helpers)

## Usage

You can start using Paco combinators and parsers by including or extending `Paco` module:

```ruby
# irb
include Paco

string("Paco").parse("Paco") #=> "Paco"
```

```ruby
# extend module
module PacoParser
  extend Paco

  class << self
    def parse(io)
      string("Paco").parse(io)
    end
  end
end

PacoParser.parse("Paco") #=> "Paco"
```

```ruby
# include in module
module PacoParser
  class << self
    include Paco

    def parse(io)
      string("Paco").parse(io)
    end
  end
end

PacoParser.parse("Paco") #=> "Paco"
```

```ruby
# include in class
class PacoParser
  include Paco

  def initialize(str)
    @str = str
  end

  def parse(io)
    string(@str).parse(io)
  end
end

PacoParser.new("Paco").parse("Paco") #=> "Paco"
```

## Paco::Combinators: Main methods

### Paco::Combinators.not_followed_by(parser)

Returns a parser that runs the passed `parser` without consuming the input, and returns `null` if the passed `parser` _does not match_ the input. Fails otherwise.

```ruby
include Paco

example = letters.skip(not_followed_by(string("?"))).skip(remainder)

example.parse("Paco!") #=> "Paco"
example.parse("Paco?") #=> Paco::ParseError
```

### Paco::Combinators.succeed(result)

Returns a parser that doesn't consume any input and always returns `result`.

```ruby
include Paco

example = seq(succeed("Paco"), remainder)

example.parse("<3") #=> ["Paco", "<3"]
```

### Paco::Combinators.failed(message)

Returns a parser that doesn't consume any input and always fails with passed `message`.

```ruby
include Paco

failed("error") #=> Paco::ParseError
```

### Paco::Combinators.lookahead(parser)

Returns a parser that runs the passed `parser` without consuming the input, and returns empty string.

```ruby
include Paco

example = seq(lookahead(string("42")), digits)

example.parse("42") #=> ["", "42"]
example.parse("424") #=> ["", "424"]
example.parse("444") #=> Paco::ParseError
```

### Paco::Combinators.alt(*parsers)

Accepts one or more parsers, and returns a parser that returns the value of the first parser that succeeds, backtracking in between.

```ruby
include Paco

example = alt(string("true"), string("false"))

example.parse("true") #=> "true"
example.parse("false") #=> "false"
example.parse("null") #=> Paco::ParseError
```

### Paco::Combinators.seq(*parsers, &block)

Accepts one or more parsers, and returns a parser that expects them to match in order, returns an array of all their results.

If `block` specified, passes results of the `parses` as an arguments to a `block`, and at the end returns its result.

```ruby
include Paco

example = seq(string("pa"), string("co"))

example.parse("paco") #=> ["pa", "co"]
example.parse("Paco") #=> Paco::ParseError

example = seq_map(string("pa"), string("co")) { |x, y| y + x }

example.parse("paco") #=> "copa"
example.parse("Paco") #=> Paco::ParseError
```

### Paco::Combinators.many(parser)

Expects `parser` zero or more times, and returns an array of the results.

```ruby
include Paco

example = many(digit)

example.parse("12") #=> ["1", "2"]
example.parse("") #=> []
example.parse("Paco") #=> Paco::ParseError
```

### Paco::Combinators.sep_by(parser, separator)

Returns a parser that expects **zero or more** matches for `parser`, separated by the parser `separator`. Returns an array of `parser` results.

```ruby
include Paco

example = sep_by(digits, string(","))

example.parse("1,1,2,3,5,8,13,21") #=> ["1", "1", "2", "3", "5", "8", "13", "21"]
example.parse("1") #=> ["1"]
example.parse("") #=> []
example.parse("Paco") #=> Paco::ParseError
```

### Paco::Combinators.sep_by!(parser, separator)

Returns a parser that expects **one or more** matches for `parser`, separated by the parser `separator`. Returns an array of `parser` results.

```ruby
include Paco

example = sep_by!(digits, string(","))

example.parse("1,1,2,3,5,8,13,21") #=> ["1", "1", "2", "3", "5", "8", "13", "21"]
example.parse("1") #=> ["1"]
example.parse("") #=> Paco::ParseError
example.parse("Paco") #=> Paco::ParseError
```

### Paco::Combinators.wrap(before, after, parser)

Expects the parser `before` before `parser` and `after` after `parser. Returns the result of the parser.

```ruby
include Paco

example = wrap(string("{"), string("}"), letters)

example.parse("{Paco}") #=> "Paco"
example.parse("{Paco") #=> Paco::ParseError
```

### Paco::Combinators.optional(parser)

Returns parser that returns result of the passed `parser` or nil if `parser` fails.

```ruby
include Paco

example = optional(string("Paco"))

example.parse("Paco") #=> "Paco"
example.parse("") #=> nil
example.parse("paco") #=> Paco::ParseError
```

### Paco::Combinators.lazy(desc = "", &block)

Accepts a block that returns a parser, which is evaluated the first time the parser is used. This is useful for referencing parsers that haven't yet been defined, and for implementing recursive parsers.

```ruby
include Paco

example = lazy { failed("always fails") }

example.parse("Paco") #=> Paco::ParseError
```

### Paco::Combinators.index

Returns parser that returns `Paco::Index` representing the current offset into the parse without consuming the input.
`Paco::Index` has a 0-based character offset attribute `:pos` and 1-based `:line` and `:column` attributes.

```ruby
include Paco

example = seq(one_of("123\n ").many.join, index, remainder)

example.parse("1\n2\n3\n\n Paco") #=> ["1\n2\n3\n\n ", #<struct Paco::Index pos=8, line=5, column=2>, "Paco"] 
```

## Paco::Combinators: Text related methods

### Paco::Combinators.string(matcher)

Returns a parser that looks for a passed `matcher` string and returns its value on success.

```ruby
include Paco

example = string("Paco")

example.parse("Paco") #=> "Paco"
example.parse("paco") #=> Paco::ParseError
```

### Paco::Combinators.satisfy(&block)

Returns a parser that returns a single character if passed block result is truthy.

```ruby
include Paco

example = satisfy { |ch| ch == ch.downcase }

example.parse("a") #=> "a"
example.parse("P") #=> Paco::ParseError
example.parse("") #=> Paco::ParseError
```

### Paco::Combinators.take_while(&block)

Returns a parser that returns a string containing all the next characters that are truthy for the passed block.

Alias for `Paco::Combinators.satisfy(&block).many.join`.

```ruby
include Paco

example = take_while { |ch| ch == ch.downcase }

example.parse("paco!") #=> "paco!"
example.parse("") #=> ""
example.parse("Paco") #=> Paco::ParseError
```

### Paco::Combinators.one_of(matcher)

Returns a parser that looks for exactly one character from passed `matcher`, and returns its value on success.

```ruby
include Paco

example = one_of("abc") # or one_of(%w[a b c]) 

example.parse("a") #=> "d"
example.parse("d") #=> Paco::ParseError
example.parse("") #=> Paco::ParseError
```

### Paco::Combinators.none_of(matcher)

Returns a parser that looks for exactly one character _NOT_ from passed `matcher`, and returns its value on success.

```ruby
include Paco

example = none_of("abc") # or none_of(%w[a b c]) 

example.parse("d") #=> "d"
example.parse("a") #=> Paco::ParseError
example.parse("") #=> Paco::ParseError
```

### Paco::Combinators.regexp(regexp, group: 0)

Returns a parser that looks for a match to the regexp and returns the entire text matched. The regexp will always match starting at the current parse location. When `group` is specified, it returns only the text in the specific regexp match group.

```ruby
include Paco

example = regexp(/[a-z]*/i)

example.parse("Paco") #=> "Paco"
example.parse("") #=> ""
example.parse("42") #=> Paco::ParseError
```

### Paco::Combinators.regexp_char(regexp)

Returns a parser that checks current character against the passed `regexp`.

```ruby
include Paco

example = regexp_char(/\d/)

example.parse("4") #=> "4"
example.parse("42") #=> Paco::ParseError
example.parse("P") #=> Paco::ParseError
example.parse("") #=> Paco::ParseError
```

### Paco::Combinators.any_char

Returns a parser that consumes and returns the next character of the input.

```ruby
include Paco

any_char.parse("P") #=> "P"
any_char.parse("4") #=> "4"
any_char.parse("Paco") #=> Paco::ParseError
any_char.parse("") #=> Paco::ParseError
```

### Paco::Combinators.remainder

Returns a parser that consumes and returns the entire remainder of the input.

```ruby
include Paco

remainder.parse("") #=> ""
remainder.parse("Paco") #=> "Paco"
```

### Paco::Combinators.eof

Returns a parser that matches end of file and returns nil.

```ruby
include Paco

eof.parse("") #=> nil
eof.parse("\n") #=> Paco::ParseError
```

### Paco::Combinators.cr

Returns a parser that checks for the "carriage return" (`\r`) character.

An alias for `Paco::Combinators.string("\r")`

```ruby
include Paco

cr.parse("\r") #=> "\r"
cr.parse("\n") #=> Paco::ParseError
cr.parse("") #=> Paco::ParseError
```

### Paco::Combinators.lf

Returns a parser that checks for the "line feed" (`\n`) character.

An alias for `Paco::Combinators.string("\n")`

```ruby
include Paco

lf.parse("\n") #=> "\n"
lf.parse("\r") #=> Paco::ParseError
lf.parse("") #=> Paco::ParseError
```

### Paco::Combinators.crlf

Returns a parser that checks for the "carriage return" character followed by the "line feed" character (`\r\n`).

An alias for `Paco::Combinators.string("\r\n")`

```ruby
include Paco

crlf.parse("\r\n") #=> "\r\n"
crlf.parse("\r") #=> Paco::ParseError
crlf.parse("") #=> Paco::ParseError
```

### Paco::Combinators.newline

Returns a parser that will match any kind of line ending.

An alias for `Combinators.alt(Paco::Combinators.crlf, Paco::Combinators.lf, Paco::Combinators.cr)`.

```ruby
include Paco

newline.parse("\r\n") #=> "\r\n"
newline.parse("\n") #=> "\n"
newline.parse("") #=> Paco::ParseError
```

### Paco::Combinators.end_of_line

Returns a parser that will match any kind of line ending *including* end of file.

An alias for `Paco::Combinators.alt(Paco::Combinators.newline, Paco::Combinators.eof)`.

```ruby
include Paco

end_of_line.parse("") #=> nil
end_of_line.parse("\n") #=> "\n"
end_of_line.parse("P") #=> Paco::ParseError
```

### Paco::Combinators.letter

Alias for `Paco::Combinators.regexp_char(/[a-z]/i)`.

```ruby
include Paco

letter.parse("p") #=> "P"
letter.parse("Paco") #=> Paco::ParseError
letter.parse("П") #=> Paco::ParseError
letter.parse("") #=> Paco::ParseError
letter.parse("42") #=> Paco::ParseError
```

### Paco::Combinators.letters

Alias for `Paco::Combinators.regexp(/[a-z]+/i)`.

```ruby
include Paco

letters.parse("Paco") #=> "Paco"
letters.parse("Пако") #=> Paco::ParseError
letters.parse("") #=> Paco::ParseError
letters.parse("42") #=> Paco::ParseError
```

### Paco::Combinators.opt_letters

Alias for `Paco::Combinators.regexp(/[a-z]*/i)`.

```ruby
include Paco

opt_letters.parse("Paco") #=> "Paco"
opt_letters.parse("") #=> ""
opt_letters.parse("Пако") #=> Paco::ParseError
opt_letters.parse("42") #=> Paco::ParseError
```

### Paco::Combinators.digit

Alias for `Paco::Combinators.regexp_char(/[0-9]/)`.

```ruby
include Paco

digit.parse("4") #=> "4"
digit.parse("42") #=> Paco::ParseError
digit.parse("") #=> Paco::ParseError
digit.parse("Paco") #=> Paco::ParseError
```

### Paco::Combinators.digits

Alias for `Paco::Combinators.regexp(/[0-9]+/)`.

```ruby
include Paco

digits.parse("42") #=> "42"
digits.parse("") #=> Paco::ParseError
digits.parse("Paco") #=> Paco::ParseError
```

### Paco::Combinators.opt_digits

Alias for `Paco::Combinators.regexp(/[0-9]*/)`.

```ruby
include Paco

opt_digits.parse("42") #=> "42"
opt_digits.parse("") #=> ""
opt_digits.parse("Paco") #=> Paco::ParseError
```

### Paco::Combinators.ws

Alias for `Paco::Combinators.regexp(/\s+/)`.

```ruby
include Paco

ws.parse("  \n  ") #=> "  \n  "
ws.parse("") #=> Paco::ParseError
ws.parse("Paco") #=> Paco::ParseError
```

### Paco::Combinators.opt_ws

Alias for `Paco::Combinators.regexp(/\s*/)`.

```ruby
include Paco

opt_ws.parse("  \n  ") #=> "  \n  "
opt_ws.parse("") #=> ""
opt_ws.parse("Paco") #=> Paco::ParseError
```

### Paco::Combinators.spaced(parser)

Alias for `parser.trim(Paco::Combinators.opt_ws)`.

```ruby
include Paco

example = spaced(letters)

example.parse("    Paco    ") #=> "Paco"
example.parse("    Paco") #=> "Paco"
example.parse("   ") #=> Paco::ParseError
```

## Paco::Parser methods

Each combinator returns a `Paco::Parser` object and all of its methods (except `Paco::Parser#parse`) returns `Paco::Parser` object, so we can chain them.

### Paco::Parser#parse(input)

Calls `parser` on the provided string `input` and returns a parsed result or raises a `ParseError` exception if parser fails or if input wasn't consumed completely.

```ruby
include Paco

example = string("Paco")

example.parse("Paco") #=> "Paco"
example.parse("paco") #=> Paco::ParseError
example.parse("Paco!") #=> Paco::ParseError
```

### Paco::Parser#or(other)

Returns a new parser which tries `parser`, and if it fails uses `other`.

```ruby
include Paco

example = string("true").or(string("false"))

example.parse("true") #=> "true"
example.parse("false") #=> "false"
example.parse("null") #=> Paco::ParseError
```

### Paco::Parser#skip(other)

Expects `other` parser to follow `parser`, but returns only the value of `parser`.

```ruby
include Paco

example = letters.skip(opt_ws)

example.parse("Paco    ") #=> "Paco"
example.parse("Paco") #=> "Paco"
example.parse("   ") #=> Paco::ParseError
```

### Paco::Parser#next(other)

Expects `other` parser to follow `parser`, but returns only the value of `other` parser.

```ruby
include Paco

example = opt_ws.next(digits)

example.parse("42") #=> "42"
example.parse("   42") #=> "42"
example.parse("   ") #=> Paco::ParseError
```

### Paco::Parser#fmap(other)

Transforms the output of `parser` with the given block.

```ruby
include Paco

example = digits.fmap(&:to_i).fmap { |num| num + 1 }

example.parse("9") #=> 10
```

### Paco::Parser#bind(other)

Returns a new parser which tries `parser`, and on success calls the `block` with the result of the parse, which is expected to return another parser, which will be called next. This allows you to dynamically decide how to continue the parse.

```ruby
include Paco

example = letters.bind { |res| ws.next(string(res.reverse)) }

example.parse("redrum murder") #=> "murder"
```

Here's a more complicated example:

```ruby
include Paco

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

```ruby
include Paco

example = digit.many

example.parse("12") #=> ["1", "2"]
example.parse("") #=> []
example.parse("Paco") #=> Paco::ParseError
```

### Paco::Parser#times(min, max = nil)

Returns a parser that runs `parser` between `min` and `max` times, and returns an array of the results. When `max` is not specified, `max` = `min`.

```ruby
include Paco

example = digit.times(2, 3)

example.parse("12") #=> ["1", "2"]
example.parse("123") #=> ["1", "2", "3"]
example.parse("1") #=> Paco::ParseError
example.parse("1234") #=> Paco::ParseError

example = digit.times(2)

example.parse("12") #=> ["1", "2"]
example.parse("1") #=> Paco::ParseError
example.parse("123") #=> Paco::ParseError
```

### Paco::Parser#at_least(num)

Returns a parser that runs `parser` at least `num` times, and returns an array of the results.

```ruby
include Paco

example = digit.at_least(2)

example.parse("1234") #=> ["1", "2", "3", "4"]
example.parse("12") #=> ["1", "2"]
example.parse("1") #=> Paco::ParseError
```

### Paco::Parser#at_most(num)

Returns a parser that runs `parser` at most `num` times, and returns an array of the results.

```ruby
include Paco

example = digit.at_most(2)

example.parse("") #=> []
example.parse("12") #=> ["1", "2"]
example.parse("123") #=> Paco::ParseError
```

### Paco::Parser#result(value)

Returns a new parser with the same behavior, but which returns passed `value`.

```ruby
include Paco

example = string("true").result(true)

example.parse("true") #=> true
example.parse("false") #=> Paco::ParseError
```

### Paco::Parser#fallback(value)

Returns a new parser which tries `parser` and, if it fails, returns `value` without consuming any input.

```ruby
include Paco

example = digit.fallback("0")

example.parse("4") #=> "4"
example.parse("") #=> "0"
```

### Paco::Parser#trim(other)

Expects `other` parser before and after `parser`. Returns the result of the parser.

```ruby
include Paco

example = letters.trim(opt_ws)

example.parse("    Paco    ") #=> "Paco"
example.parse("    Paco") #=> "Paco"
example.parse("   ") #=> Paco::ParseError
```

### Paco::Parser#wrap(before, after)

Expects the parser `before` before `parser` and `after` after `parser. Returns the result of the parser.

```ruby
include Paco

example = letters.wrap(string("{"), string("}"))

example.parse("{Paco}") #=> "Paco"
example.parse("{Paco") #=> Paco::ParseError
```

### Paco::Parser#not_followed_by(other)

Returns a parser that runs the passed `other` parser without consuming the input, and returns result of the `parser` if the passed one _does not match_ the input. Fails otherwise.

```ruby
include Paco

example = letters.not_followed_by(string("?")).skip(remainder)

example.parse("Paco!") #=> "Paco"
example.parse("Paco?") #=> Paco::ParseError
```

### Paco::Parser#join(separator = "")

Returns a parser that runs `parser` and concatenate it results with the `separator`.

```ruby
include Paco

many(letter).join(" ").parse("Paco") #=> "P a c o"
many(letter).join.parse("Paco") #=> "Paco"
```

## Debugging

Pass `with_callstack: true` to the `Paco::Parser#parse` method to collect a callstack while parsing. To examine the callstack catch the `ParseError` exception:

```ruby
begin
  string("Paco").parse("Paco!", with_callstack: true)
rescue Paco::ParseError => e
  pp e.callstack.stack # You will probably want to use `binding.irb` or `binding.pry`
end
#=>
# [
#   {:pos=>0, :status=>:start, :depth=>1, :parser=>"string(\"Paco\").skip(end of file)"},
#   {:pos=>0, :status=>:start, :depth=>2, :parser=>"seq(string(\"Paco\"), end of file)"},
#   {:pos=>0, :status=>:start, :depth=>3, :parser=>"string(\"Paco\")"},
#   {:pos=>4, :status=>:success, :depth=>2, :result=>"Paco", :parser=>"string(\"Paco\")"},
#   {:pos=>4, :status=>:start, :depth=>3, :parser=>"end of file"},
#   {:pos=>4, :status=>:failure, :depth=>2, :parser=>"end of file"}
# ]
```

## Test helpers

Paco provides a special RSpec helper, add `require "paco/rspec"` to `spec_helper.rb` to enable `#parse` matcher:

```ruby
subject { string("Paco") }

it { is_expected.to parse("Paco") } # just checks if parser succeeds
it { is_expected.to parse("Paco").as("Paco") } # checks if parser result is eq to value passed to `#as`
it { is_expected.to parse("Paco").fully } # checks if parser result is the same as value passed to `#parse`
it { is_expected.not_to parse("paco") } # checks if parser failed
```
