# frozen_string_literal: true

require "paco"

module JsonParser
  extend Paco
  prepend MemoWise

  module_function

  def parse(io)
    spaced(value).parse(io)
  end

  def value
    alt(null, bool, number, str, array, object)
  end
  memo_wise :value

  def null
    string("null").result(nil)
  end
  memo_wise :null

  def bool
      alt(
        string("true").result(true),
        string("false").result(false)
      )
  end
  memo_wise :bool

  def sign
    alt(string("-"), string("+"))
  end
  memo_wise :sign

  def decimal
    digits.fmap(&:to_i)
  end
  memo_wise :decimal

  def number
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
  memo_wise :number

  def str
    wrap(
      string('"'),
      string('"'),
      many(alt(none_of('"\\'), escaped_chars)).join
    )
  end
  memo_wise :str

  def array
    wrap(
      string("["),
      opt_ws > string("]"),
      sep_by(spaced(lazy { value }), string(","))
    )
  end
  memo_wise :array

  def object
    wrap(string("{"), opt_ws > string("}"),
      sep_by(
        spaced(seq(
          str < spaced(string(":")),
          lazy { value }
        )),
        string(",")
      )).fmap { |x| x.to_h }
  end
  memo_wise :object

  def four_hex_digits
    regexp(/\h{4}/)
  end
  memo_wise :four_hex_digits

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
