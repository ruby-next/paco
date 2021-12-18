# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog],
and this project adheres to [Semantic Versioning].

## [Unreleased]

### Added

- Callstack collection for debugging. ([@skryukov])

Pass `with_callstack: true` to the `Paco::Parser#parse` method to collect a callstack while parsing. To examine the callstack catch the `ParseError` exception:

```ruby
begin
  string("Paco").parse("Paco!", with_callstack: true)
rescue Paco::ParseError => e
  pp e.callstack.stack # You will probably want to use `binding.irb` or `binding.pry`
end
```

### Fixed

- `Paco::Combinators::Char#regexp` now uses `\A` instead of `^`. ([@skryukov])
- `include Paco` now works inside `irb`. ([@skryukov])
- `Paco::Combinators#not_followed_by` now doesn't consume input on error. ([@skryukov])

## [0.1.0]

### Added

- Initial implementation. ([@skryukov])

[@skryukov]: https://github.com/skryukov

[Unreleased]: https://github.com/skryukov/paco/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/skryukov/paco/commits/v0.1.0

[Keep a Changelog]: https://keepachangelog.com/en/1.0.0/
[Semantic Versioning]: https://semver.org/spec/v2.0.0.html
