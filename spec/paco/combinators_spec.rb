# frozen_string_literal: true

require "spec_helper"

RSpec.describe Paco::Combinators, :include_combinators do
  describe "#not_followed_by" do
    subject { seq(not_followed_by(string("a")), string("b")) }

    it { is_expected.to parse("b").as([nil, "b"]) }

    it "raises an error without consuming input" do
      expect { not_followed_by(string("a")).parse("a") }.to raise_error(Paco::ParseError) do |err|
        expect(err.ctx.pos).to eq(0)
      end
    end
  end

  describe "#lookahead" do
    subject { seq(lookahead(string("42")), digits) }

    it { is_expected.to parse("42").as(["", "42"]) }

    it "raises an error" do
      expect { lookahead(string("Alf")).parse("Paco") }.to raise_error(Paco::ParseError) do |err|
        expect(err.ctx.pos).to eq(0)
      end
    end
  end

  describe "#succeed" do
    subject { seq(succeed("Paco"), remainder) }

    it { is_expected.to parse("<3").as(%w[Paco <3]) }
  end

  describe "#failed" do
    subject { seq(failed("message"), remainder) }

    it { is_expected.not_to parse("Paco") }
  end

  describe "#alt" do
    subject { alt(string("true"), string("false")) }

    it { is_expected.to parse("true").fully }
    it { is_expected.to parse("false").fully }
    it { is_expected.not_to parse("null") }

    it "raises an error when no parsers passed" do
      expect { alt.parse("Paco") }.to raise_error(ArgumentError)
    end

    context "when first parser is less specific" do
      subject { alt(string("t").skip(remainder), string("true")) }

      it { is_expected.to parse("true").as("t") }
    end
  end

  describe "#seq" do
    subject { seq(string("pa"), string("co")) }

    it { is_expected.to parse("paco").as(%w[pa co]) }

    it "raises an error" do
      expect { subject.parse("paCo") }.to raise_error(Paco::ParseError) do |err|
        expect(err.ctx.pos).to eq(0)
      end
    end

    it "raises an error when no parsers passed" do
      expect { seq.parse("Paco") }.to raise_error(ArgumentError)
    end

    context "with block passed" do
      subject { seq(string("pa"), string("co")) { |x, y| y + x }.skip(remainder) }
      it { is_expected.to parse("paco!").as("copa") }
      it { is_expected.not_to parse("Paco") }
    end
  end

  describe "#many" do
    subject { many(digit).skip(remainder) }

    it { is_expected.to parse("123").as(%w[1 2 3]) }
    it { is_expected.to parse("Paco").as([]) }
  end

  describe "#optional" do
    subject { optional(string("Paco")).skip(remainder) }

    it { is_expected.to parse("Paco!").as("Paco") }
    it { is_expected.to parse("paco").as(nil) }
  end

  describe "#sep_by" do
    subject { sep_by(digits, string(",")) }

    it { is_expected.to parse("1,2,3").as(%w[1 2 3]) }
    it { is_expected.not_to parse(",2,3") }

    it "returns empty array when nothing to parse" do
      expect(subject.skip(remainder)).to parse("paco").as([])
    end
  end

  describe "#sep_by!" do
    subject { sep_by!(digits, string(",")) }

    it { is_expected.to parse("1,2,3").as(%w[1 2 3]) }
    it { is_expected.not_to parse(",2,3") }

    it "raises an error when nothing to parse" do
      expect(subject.skip(remainder)).not_to parse("paco")
    end
  end

  describe "#wrap" do
    subject { wrap(string("{"), string("}"), letters) }

    it { is_expected.to parse("{Paco}").as("Paco") }
    it { is_expected.not_to parse("{Пако}") }
    it { is_expected.not_to parse("{Paco") }
  end

  describe "#lazy" do
    subject { lazy { failed("message") } }

    it "doesn't call the block on reference" do
      expect { subject }.not_to raise_error
    end

    it "calls the block on parsing" do
      expect(subject).not_to parse("Paco")
    end
  end

  describe "#index" do
    it "returns index" do
      expect(index).to parse("").as(Paco::Index.new(0, 1, 1))
    end
  end
end
