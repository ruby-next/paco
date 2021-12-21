# frozen_string_literal: true

require "spec_helper"

RSpec.describe Paco::Combinators::Char, :include_combinators do
  describe "#string" do
    subject { string("Paco") }

    it { is_expected.to parse("Paco").fully }
    it { is_expected.not_to parse("paco") }
  end

  describe "#satisfy" do
    subject { satisfy { |ch| ch == ch.downcase }.skip(remainder) }

    it { is_expected.to parse("paco").as("p") }
    it { is_expected.not_to parse("Paco") }
  end

  describe "#take_while" do
    subject { take_while { |ch| ch == ch.downcase }.skip(remainder) }

    it { is_expected.to parse("come here, Paco").as("come here, ") }
    it { is_expected.to parse("Paco").as("") }
  end

  describe "#one_of" do
    subject { one_of("abc") }

    it { is_expected.to parse("b").fully }
    it { is_expected.not_to parse("d") }

    context "when passed array" do
      subject { one_of(%w[a b c]) }

      it { is_expected.to parse("b").fully }
      it { is_expected.not_to parse("d") }
    end
  end

  describe "#none_of" do
    subject { none_of("abc") }

    it { is_expected.to parse("p").fully }
    it { is_expected.not_to parse("a") }

    context "when passed array" do
      subject { none_of(%w[a b c]) }

      it { is_expected.to parse("A").fully }
      it { is_expected.not_to parse("b") }
    end
  end

  describe "#regexp" do
    subject { regexp(/\w{4}/) }

    it { is_expected.to parse("Paco").fully }
    it { is_expected.not_to parse("Alf") }

    it "returns matched parts of the string" do
      parser = seq(regexp(/pa/i), regexp(/\w+/))
      expect(parser).to parse("Paco").as(%w[Pa co])
    end

    context "with groups in regex" do
      it "returns matched part of the string" do
        expect(regexp(/(\w)\w*/)).to parse("Paco").as("Paco")
      end

      it "returns specified group" do
        expect(regexp(/(\w{4}).*/, group: 1)).to parse("Paco!!!!111").as("Paco")
      end
    end
  end

  describe "#regexp_char" do
    subject { regexp_char(/\w/).skip(remainder) }

    it { is_expected.to parse("Paco").as("P") }
    it { is_expected.not_to parse("П") }
  end

  describe "#cr" do
    subject { cr }

    it { is_expected.to parse("\r").fully }
    it { is_expected.not_to parse("\n") }
  end

  describe "#lf" do
    subject { lf }

    it { is_expected.to parse("\n").fully }
    it { is_expected.not_to parse("\r") }
  end

  describe "#crlf" do
    subject { crlf }

    it { is_expected.to parse("\r\n").fully }
    it { is_expected.not_to parse("\r") }
  end

  describe "#newline" do
    subject { newline }

    it { is_expected.to parse("\n").fully }
    it { is_expected.to parse("\r").fully }
    it { is_expected.to parse("\r\n").fully }
    it { is_expected.not_to parse("") }
    it { is_expected.not_to parse("paco") }
  end

  describe "#end_of_line" do
    subject { end_of_line }

    it { is_expected.to parse("\n").fully }
    it { is_expected.to parse("\r").fully }
    it { is_expected.to parse("\r\n").fully }
    it { is_expected.to parse("").as(nil) }
    it { is_expected.not_to parse("paco") }
  end

  describe "#any_char" do
    subject { any_char }

    it { is_expected.to parse("П").fully }
    it { is_expected.not_to parse("") }
  end

  describe "#remainder" do
    subject { remainder }

    it { is_expected.to parse("Paco <3").fully }
    it { is_expected.to parse("").fully }
  end

  describe "#eof" do
    subject { eof }

    it { is_expected.to parse("").as(nil) }
    it { is_expected.not_to parse("Paco") }
  end

  describe "#letter" do
    subject { letter }

    it { is_expected.to parse("Z").fully }
    it { is_expected.not_to parse("1") }
    it { is_expected.not_to parse("П") }
  end

  describe "#letters" do
    subject { letters }

    it { is_expected.to parse("Paco").fully }
    it { is_expected.not_to parse("Пако") }
    it { is_expected.not_to parse("42") }
  end

  describe "#opt_letters" do
    subject { opt_letters }

    it { is_expected.to parse("Paco").fully }
    it { is_expected.to parse("").fully }

    it "returns empty string" do
      expect(subject.skip(remainder)).to parse("Пако").as("")
    end
  end

  describe "#digit" do
    subject { digit }

    it "returns parsed char" do
      expect(subject.skip(remainder)).to parse("42").as("4")
    end

    it { is_expected.not_to parse("a") }
  end

  describe "#digits" do
    subject { digits }

    it "returns parsed chars" do
      expect(subject.skip(remainder)).to parse("42").as("42")
    end

    it { is_expected.not_to parse("Paco") }
  end

  describe "#opt_digits" do
    subject { opt_digits }

    it "returns parsed chars" do
      expect(subject.skip(remainder)).to parse("42!").as("42")
    end

    it "returns empty string" do
      expect(subject.skip(remainder)).to parse("Paco").as("")
    end

    it { is_expected.to parse("").fully }
  end

  describe "#ws" do
    subject { ws }

    it "returns parsed chars" do
      expect(subject.skip(remainder)).to parse("   Paco").as("   ")
    end

    it { is_expected.not_to parse("Paco") }
  end

  describe "#opt_ws" do
    subject { opt_ws }

    it "returns parsed chars" do
      expect(subject.skip(remainder)).to parse("   Paco").as("   ")
    end

    it "returns empty string" do
      expect(subject.skip(remainder)).to parse("Paco").as("")
    end
  end

  describe "#spaced" do
    subject { spaced(letters).skip(remainder) }

    it { is_expected.to parse("   Hello    Paco!").as("Hello") }
    it { is_expected.to parse("Paco").fully }

    it { is_expected.not_to parse("!") }
  end
end
