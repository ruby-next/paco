# frozen_string_literal: true

require "paco"

module JsonParser
  extend Paco

  module_function

  def parse(io)
    spaced(value).parse(io)
  end

  def value
    memoize { alt(null, bool, number, str, array, object) }
  end

  def null
    memoize { string("null").result(nil) }
  end

  def bool
    memoize do
      alt(
        string("true").result(true),
        string("false").result(false)
      )
    end
  end

  def sign
    memoize { alt(string("-"), string("+")) }
  end

  def decimal
    memoize { digits.fmap(&:to_i) }
  end

  def number
    memoize do
      seq(
        optional(sign),
        decimal,
        optional(seq(
          string("."),
          decimal
        )),
        optional(seq(
          one_of("eE"),
          optional(sign),
          decimal
        ))
      ).fmap do |sign, whole, (_, fractional), (_, exponent_sign, exponent)|
        n = whole
        n += fractional.to_f / 10**fractional.to_s.length if fractional
        n *= -1 if sign == "-"
        if exponent
          e = exponent
          e *= -1 if exponent_sign == "-"
          n *= 10**e
        end
        n
      end
    end
  end

  def str
    memoize do
      wrap(
        string('"'),
        string('"'),
        many(alt(none_of('"\\'), escaped_chars)).join
      )
    end
  end

  def array
    memoize do
      wrap(
        string("["),
        opt_ws > string("]"),
        sep_by(spaced(lazy { value }), string(","))
      )
    end
  end

  def object
    memoize do
      wrap(string("{"), opt_ws > string("}"),
        sep_by(
          spaced(seq(
            str < spaced(string(":")),
            lazy { value }
          )),
          string(",")
        )).fmap { |x| x.to_h }
    end
  end

  def four_hex_digits
    memoize { regexp(/\h{4}/) }
  end

  def escaped_chars
    string("\\").next(
      alt(
        string('"'),
        string("\\"),
        string("/"),
        string("f").result("\f"),
        string("b").result("\b"),
        string("r").result("\r"),
        string("n").result("\n"),
        string("t").result("\t"),
        string("u").next(four_hex_digits.fmap { |s| [s.hex].pack("U") })
      )
    )
  end
end
