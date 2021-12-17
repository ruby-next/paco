# frozen_string_literal: true

require "spec_helper"

RSpec.describe Paco::Combinators, :include_combinators do
  describe "#not_followed_by" do
    it "returns nil" do
      parser = seq(not_followed_by(string("a")), string("b"))
      expect(parser.parse("b")).to eq([nil, "b"])
    end

    it "raises an error" do
      expect { not_followed_by(string("a")).parse("a") }.to raise_error(Paco::ParseError)
    end
  end

  describe "#lookahead" do
    it "returns empty string" do
      parser = seq(lookahead(string("42")), digits)
      expect(parser.parse("42")).to eq(["", "42"])
    end

    it "raises an error" do
      expect { lookahead(string("Alf")).parse("Paco") }.to raise_error(Paco::ParseError)
    end
  end

  describe "#succeed" do
    it "returns passed value" do
      parser = seq(succeed("Paco"), remainder)
      expect(parser.parse("<3")).to eq(%w[Paco <3])
    end
  end

  describe "#failed" do
    it "raises an error" do
      parser = seq(failed("message"), remainder)
      expect { parser.parse("Paco") }.to raise_error(Paco::ParseError)
    end
  end

  describe "#alt" do
    let(:alt_true_or_false) { alt(string("true"), string("false")) }
    let(:alt_t_or_true) { alt(string("t").skip(remainder), string("true")) }

    it "returns passed parser result" do
      expect(alt_true_or_false.parse("true")).to eq("true")
    end

    it "returns passed parser result" do
      expect(alt_true_or_false.parse("false")).to eq("false")
    end

    it "returns first passed parser result" do
      expect(alt_t_or_true.parse("true")).to eq("t")
    end

    it "raises an error" do
      expect { alt_true_or_false.parse("null") }.to raise_error(Paco::ParseError)
    end

    it "raises an error when no parsers passed" do
      expect { alt.parse("Paco") }.to raise_error(ArgumentError)
    end
  end

  describe "#seq" do
    let(:example) { seq(string("pa"), string("co")) }

    it "returns array of parsers results" do
      expect(example.parse("paco")).to eq(%w[pa co])
    end

    it "raises an error" do
      expect { example.parse("Paco") }.to raise_error(Paco::ParseError)
    end

    it "raises an error when no parsers passed" do
      expect { seq.parse("Paco") }.to raise_error(ArgumentError)
    end

    context "with block passed" do
      let(:example) do
        seq(string("pa"), string("co")) { |x, y| y + x }.skip(remainder)
      end

      it "returns result of the block" do
        expect(example.parse("paco!")).to eq("copa")
      end

      it "raises an error when parser fails" do
        expect { example.parse("Paco") }.to raise_error(Paco::ParseError)
      end
    end
  end

  describe "#many" do
    let(:example) { many(digit).skip(remainder) }

    it "returns parsed result" do
      expect(example.parse("123")).to eq(%w[1 2 3])
    end

    it "returns empty array when parser fails" do
      expect(example.parse("Paco")).to eq([])
    end
  end

  describe "#optional" do
    let(:example) { optional(string("Paco")).skip(remainder) }

    it "returns parsed result" do
      expect(example.parse("Paco!")).to eq("Paco")
    end

    it "returns nil when parser fails" do
      expect(example.parse("paco")).to be_nil
    end
  end

  describe "#sep_by" do
    let(:example) { sep_by(digits, string(",")) }

    it "returns array of parsed results" do
      expect(example.parse("1,2,3")).to eq(%w[1 2 3])
    end

    it "returns array of parsed results with trailing separator" do
      expect(example.parse("1,2,3,")).to eq(%w[1 2 3])
    end

    it "returns empty array when nothing to parse" do
      expect(example.skip(remainder).parse("paco")).to eq([])
    end

    it "raises an error when parser fails" do
      expect { example.parse(",2,3") }.to raise_error(Paco::ParseError)
    end
  end

  describe "#sep_by!" do
    let(:example) { sep_by!(digits, string(",")) }

    it "returns array of parsed results" do
      expect(example.parse("1,2,3")).to eq(%w[1 2 3])
    end

    it "returns array of parsed results with trailing separator" do
      expect(example.parse("1,2,3,")).to eq(%w[1 2 3])
    end

    it "raises an error when nothing to parse" do
      expect { example.skip(remainder).parse("paco") }.to raise_error(Paco::ParseError)
    end

    it "raises an error when parser fails" do
      expect { example.parse(",2,3") }.to raise_error(Paco::ParseError)
    end
  end

  describe "#wrap" do
    let(:example) { wrap(string("{"), string("}"), letters) }

    it "returns parser result" do
      expect(example.parse("{Paco}")).to eq("Paco")
    end

    it "raises an error when wrapped parser fails" do
      expect { example.parse("{Пако}") }.to raise_error(Paco::ParseError)
    end

    it "raises an error when wrapping parser fails" do
      expect { example.parse("{Paco") }.to raise_error(Paco::ParseError)
    end
  end

  describe "#lazy" do
    let(:example) { lazy { failed("message") } }

    it "doesn't call the block on reference" do
      expect { example }.not_to raise_error
    end

    it "calls the block on parsing" do
      expect { example.parse("Paco") }.to raise_error(Paco::ParseError)
    end
  end
end
