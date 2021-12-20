# Paco

[![Gem Version](https://badge.fury.io/rb/paco.svg)](https://rubygems.org/gems/paco)
[![Build](https://github.com/skryukov/paco/workflows/Build/badge.svg)](https://github.com/skryukov/paco/actions)

Paco is a parser combinator library inspired by Haskell's [Parsec] and [Parsimmon].

"But I don't need to write another JSON parser or a new language, why do I need your library then?"

Well, most probably you don't. But I can think of rare cases when you do. Say, you need to write a validation for [git branch names].

You can go with easy-peasy regex:

```ruby
branch_name_regex = /^(?!\/|.*(?:[\/.]\.|\/\/|@{|\\|\.lock$|[\/.]$))[^\040\177 ~^:?*\[]+$/

branch_name_regex.match?("feature/branch-validation")
```

With Paco, you can go with a little more verbose version of that rule:

```ruby
module BranchNameParser
  extend Paco

  class << self
    def parse(input)
      parser.parse(input)
    end

    def parser
      lookahead(none_of("/")).next(valid_chars.join)
    end

    def valid_chars
      any_char.not_followed_by(invalid_sequences).at_least(1)
    end
    
    def invalid_sequences
      alt(invalid_chars, invalid_endings)
    end

    def invalid_chars
      alt(
        string("/."),
        string(".."),
        string("//"),
        string("@{"),
        string("\\\\"),
        one_of("\040\177 ~^:?*\\[")
      )
    end

    def invalid_endings
      seq(
        alt(string(".lock"), one_of("/.")),
        eof
      )
    end
  end
end

BranchNameParser.parse("feature/branch-validation")
```

Easy? Not really, but there is a chance you can read it. 😅

See [API documentation](docs/paco.md), [examples](examples) and [specs](spec) for more info on usage.

<a href="https://evilmartians.com/"><img src="https://evilmartians.com/badges/sponsored-by-evil-martians.svg" alt="Sponsored by Evil Martians" width="236" height="54"></a>

## Installation

Add to your `Gemfile`:

```ruby
gem "paco"
```

And then run `bundle install`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/skryukov/paco.

## Alternatives

- [parslet] - A small (but featureful) PEG based parser library.
- [parsby] — Parser combinator library for Ruby inspired by Haskell's Parsec.

## License

The gem is available as open source under the terms of the [MIT License].

[MIT License]: https://opensource.org/licenses/MIT
[Parsec]: https://github.com/haskell/parsec
[Parsimmon]: https://github.com/jneen/parsimmon
[parslet]: https://github.com/kschiess/parslet
[parsby]: https://github.com/jolmg/parsby
[git branch names]: https://git-scm.com/docs/git-check-ref-format#_description
