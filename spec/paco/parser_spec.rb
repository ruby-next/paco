# frozen_string_literal: true

require "spec_helper"

RSpec.describe Paco::Parser, :include_combinators do
  describe "#parse" do
    it "parses string" do
      expect(string("Paco")).to parse("Paco").fully
    end

    it "parses Paco::Context" do
      context = Paco::Context.new("Paco")
      expect(string("Paco")).to parse(context).as("Paco")
    end
  end

  describe "#or" do
    subject { failed("msg").or(string("Paco")) }

    it { is_expected.to parse("Paco").fully }
    it { is_expected.not_to parse("paco") }
  end

  describe "#skip" do
    subject { string("Pa").skip(string("co")) }

    it { is_expected.to parse("Paco").as("Pa") }
    it { is_expected.not_to parse("paco") }
  end

  describe "#next" do
    subject { string("Pa").next(string("co")) }

    it { is_expected.to parse("Paco").as("co") }
    it { is_expected.not_to parse("paco") }
  end

  describe "#fmap" do
    subject { string("Paco").fmap(&:upcase) }

    it { is_expected.to parse("Paco").as("PACO") }
  end

  describe "#bind" do
    subject { letters.bind { |res| ws.next(string(res.upcase)) } }

    it { is_expected.to parse("Paco PACO").as("PACO") }
  end

  describe "#many" do
    subject { digit.many.skip(remainder) }

    it { is_expected.to parse("123").as(%w[1 2 3]) }
    it { is_expected.to parse("Paco").as([]) }
  end

  describe "#result" do
    subject { string("Paco").result(true) }

    it { is_expected.to parse("Paco").as(true) }
    it { is_expected.not_to parse("paco") }
  end

  describe "#fallback" do
    subject { string("Paco").fallback("<null>").skip(remainder) }

    it { is_expected.to parse("Paco").fully }
    it { is_expected.to parse("paco").as("<null>") }
  end

  describe "#trim" do
    subject { letters.trim(string(" ")) }

    it { is_expected.to parse(" Paco ").as("Paco") }
    it { is_expected.not_to parse(" Пако ") }
    it { is_expected.not_to parse("    Paco ") }
  end

  describe "#wrap" do
    subject { letters.wrap(string("{"), string("}")) }

    it { is_expected.to parse("{Paco}").as("Paco") }
    it { is_expected.not_to parse("{Пако}") }
    it { is_expected.not_to parse("{Paco") }
  end

  describe "#not_followed_by" do
    subject { string("a").not_followed_by(string("b")).skip(remainder) }

    it { is_expected.to parse("ac").as("a") }
    it { is_expected.not_to parse("ab") }
  end

  describe "#join" do
    subject { letter.many.join }

    it { is_expected.to parse("abc").fully }

    context "when separator passed" do
      subject { letter.many.join(",") }

      it { is_expected.to parse("abc").as("a,b,c") }
    end
  end

  describe "#times" do
    subject { digit.times(2).skip(remainder) }

    it { is_expected.to parse("1111").as(%w[1 1]) }
    it { is_expected.not_to parse("1a") }

    context "with min and max are specified" do
      subject { digit.times(2, 3).skip(remainder) }

      it { is_expected.to parse("1111").as(%w[1 1 1]) }
      it { is_expected.to parse("11a").as(%w[1 1]) }
      it { is_expected.not_to parse("1a") }
    end

    context "with invalid arguments" do
      it "raises an error" do
        expect { digit.times(-1, 3).parse("11") }.to raise_error(ArgumentError)
      end

      it "raises an error" do
        expect { digit.times(3, 2).parse("11") }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#at_least" do
    subject { digit.at_least(2).skip(remainder) }

    it { is_expected.to parse("111a").as(%w[1 1 1]) }
    it { is_expected.not_to parse("1a") }
  end

  describe "#at_most" do
    subject { digit.at_most(2).skip(remainder) }

    it { is_expected.to parse("1111").as(%w[1 1]) }
    it { is_expected.to parse("Paco").as(%w[]) }
  end
end
