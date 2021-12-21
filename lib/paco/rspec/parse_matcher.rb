# frozen_string_literal: true

RSpec::Matchers.define(:parse) do |input|
  chain :as do |expected_output = nil, &block|
    @expected = expected_output
    @block = block
  end

  chain :fully do
    @expected = input
  end

  match do |parser|
    @result = parser.parse(input)
    return @block.call(@result) if @block
    return @expected == @result if defined?(@expected)

    true
  rescue Paco::ParseError => e
    @error_message = e.message
    false
  end

  failure_message do |subject|
    msg = "expected output of parsing #{input.inspect} with #{subject.inspect} to"
    was = (@result ? "was #{@result.inspect}" : "raised an error #{@error_message}")
    return "#{msg} meet block conditions, but it didn't. It #{was}" if @block
    return "#{msg} equal #{@expected.inspect}, but it #{was}" if defined?(@expected)

    "expected #{subject.inspect} to successfully parse #{input.inspect}, but it #{was}"
  end

  failure_message_when_negated do |subject|
    msg = "expected output of parsing #{input.inspect} with #{subject.inspect} not to"
    return "#{msg} meet block conditions, but it did" if @block
    return "#{msg} equal #{@expected.inspect}" if defined?(@expected)

    "expected #{subject.inspect} to not parse #{input.inspect}, but it did"
  end

  description do
    return "parse #{input.inspect} with block conditions" if @block
    return "parse #{input.inspect} as #{@expected.inspect}" if defined?(@expected)

    "parse #{input.inspect}"
  end
end
