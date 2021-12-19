# frozen_string_literal: true

require "spec_helper"

RSpec.describe Paco::Combinators::Char, :include_combinators do
  describe "#string" do
    it "matches a string" do
      expect(string("Paco").parse("Paco")).to eq "Paco"
    end

    it "raises an error" do
      expect { string("Paco").parse("paco") }.to raise_error(Paco::ParseError)
    end
  end

  describe "#satisfy" do
    let(:example) { satisfy { |ch| ch == ch.downcase }.skip(remainder) }

    it "matches characters from string and returns an array" do
      expect(example.parse("paco")).to eq "p"
    end

    it "raises an error" do
      expect { example.parse("Paco") }.to raise_error(Paco::ParseError)
    end
  end

  describe "#take_while" do
    let(:example) { take_while { |ch| ch == ch.downcase }.skip(remainder) }

    it "matches characters from string and returns an array" do
      expect(example.parse("come here, Paco")).to eq "come here, "
    end

    it "returns empty string if no matches found" do
      expect(example.parse("Paco")).to eq ""
    end
  end

  describe "#one_of" do
    it "matches a character from string" do
      expect(one_of("abc").parse("b")).to eq "b"
    end

    it "matches a character from array" do
      expect(one_of(%w[a b c]).parse("c")).to eq "c"
    end

    it "raises an error" do
      expect { one_of("abc").parse("d") }.to raise_error(Paco::ParseError)
    end
  end

  describe "#none_of" do
    it "matches a character not from string" do
      expect(none_of("abc").parse("p")).to eq "p"
    end

    it "matches a character not from array" do
      expect(none_of(%w[a b c]).parse("A")).to eq "A"
    end

    it "raises an error" do
      expect { none_of("a b c").parse("b") }.to raise_error(Paco::ParseError)
    end
  end

  describe "#regexp" do
    it "returns matched part of the string" do
      expect(regexp(/\w{4}/).parse("Paco")).to eq("Paco")
    end

    it "returns matched parts of the string" do
      parser = seq(regexp(/pa/i), regexp(/\w+/))
      expect(parser.parse("Paco")).to eq(%w[Pa co])
    end

    it "raises an error" do
      expect { regexp(/\w{4}/).parse("Alf") }.to raise_error(Paco::ParseError)
    end

    context "with groups in regex" do
      it "returns matched part of the string" do
        expect(regexp(/(\w)\w*/).parse("Paco")).to eq("Paco")
      end

      it "returns specified group" do
        expect(regexp(/(\w{4}).*/, group: 1).parse("Paco!!!!111")).to eq("Paco")
      end
    end
  end

  describe "#regexp_char" do
    let(:example) { regexp_char(/\w/).skip(remainder) }

    it "returns matched char" do
      expect(example.parse("Paco")).to eq("P")
    end

    it "raises an error" do
      expect { example.parse("П") }.to raise_error(Paco::ParseError)
    end
  end

  describe "#cr" do
    it "returns cr" do
      expect(cr.parse("\r")).to eq("\r")
    end

    it "raises an error" do
      expect { cr.parse("\n") }.to raise_error(Paco::ParseError)
    end
  end

  describe "#lf" do
    it "returns lf" do
      expect(lf.parse("\n")).to eq("\n")
    end

    it "raises an error" do
      expect { lf.parse("\r") }.to raise_error(Paco::ParseError)
    end
  end

  describe "#crlf" do
    it "returns crlf" do
      expect(crlf.parse("\r\n")).to eq("\r\n")
    end

    it "raises an error" do
      expect { crlf.parse("\r") }.to raise_error(Paco::ParseError)
    end
  end

  describe "#newline" do
    subject { newline }

    it "returns parsed chars", :aggregate_failures do
      expect(subject.parse("\n")).to eq("\n")
      expect(subject.parse("\r")).to eq("\r")
      expect(subject.parse("\r\n")).to eq("\r\n")
    end

    it "raises an error" do
      expect { subject.parse("") }.to raise_error(Paco::ParseError)
      expect { subject.parse("paco") }.to raise_error(Paco::ParseError)
    end
  end

  describe "#end_of_line" do
    subject { end_of_line }

    it "returns parsed chars", :aggregate_failures do
      expect(subject.parse("\n")).to eq("\n")
      expect(subject.parse("\r")).to eq("\r")
      expect(subject.parse("\r\n")).to eq("\r\n")
      expect(subject.parse("")).to be_nil
    end

    it "raises an error" do
      expect { subject.parse("paco") }.to raise_error(Paco::ParseError)
    end
  end

  describe "#any_char" do
    it "returns parsed char" do
      expect(any_char.parse("П")).to eq("П")
    end

    it "raises an error" do
      expect { any_char.parse("") }.to raise_error(Paco::ParseError)
    end
  end

  describe "#remainder" do
    it "returns parsed char" do
      expect(remainder.parse("Paco <3")).to eq("Paco <3")
    end

    it "returns empty string when eof" do
      expect(remainder.parse("")).to eq("")
    end
  end

  describe "#eof" do
    it "returns parsed char" do
      expect(eof.parse("")).to be_nil
    end

    it "raises an error" do
      expect { eof.parse("Paco") }.to raise_error(Paco::ParseError)
    end
  end

  describe "#letter" do
    it "returns parsed char" do
      expect(letter.parse("Z")).to eq("Z")
    end

    it "raises an error" do
      expect { letter.parse("1") }.to raise_error(Paco::ParseError)
    end

    it "raises an error for non a-z letters" do
      expect { letter.parse("П") }.to raise_error(Paco::ParseError)
    end
  end

  describe "#letters" do
    it "returns parsed char" do
      expect(letters.parse("Paco")).to eq("Paco")
    end

    it "raises an error for non a-z letters" do
      expect { letter.parse("Пако") }.to raise_error(Paco::ParseError)
    end

    it "raises an error" do
      expect { letters.parse("42") }.to raise_error(Paco::ParseError)
    end
  end

  describe "#opt_letters" do
    it "returns parsed chars" do
      expect(opt_letters.parse("Paco")).to eq("Paco")
    end

    it "returns empty string" do
      expect(opt_letters.skip(remainder).parse("Пако")).to eq("")
    end
  end

  describe "#digit" do
    it "returns parsed char" do
      expect(digit.skip(remainder).parse("42!")).to eq("4")
    end

    it "raises an error" do
      expect { digit.parse("a") }.to raise_error(Paco::ParseError)
    end
  end

  describe "#digits" do
    it "returns parsed chars" do
      expect(digits.skip(remainder).parse("42!")).to eq("42")
    end

    it "raises an error" do
      expect { digits.parse("Paco") }.to raise_error(Paco::ParseError)
    end
  end

  describe "#opt_digits" do
    it "returns parsed chars" do
      expect(opt_digits.skip(remainder).parse("42!")).to eq("42")
    end

    it "returns empty string" do
      expect(opt_digits.skip(remainder).parse("Paco")).to eq("")
    end
  end

  describe "#ws" do
    it "returns parsed chars" do
      expect(ws.skip(remainder).parse("   Paco")).to eq("   ")
    end

    it "raises an error" do
      expect { ws.parse("Paco") }.to raise_error(Paco::ParseError)
    end
  end

  describe "#opt_ws" do
    it "returns parsed chars" do
      expect(opt_ws.skip(remainder).parse("   Paco")).to eq("   ")
    end

    it "returns empty string" do
      expect(opt_ws.skip(remainder).parse("Paco")).to eq("")
    end
  end

  describe "#spaced" do
    let(:example) { spaced(letters).skip(remainder) }

    it "returns parser results" do
      expect(example.parse("   Hello    Paco!")).to eq("Hello")
    end

    it "returns parser results when no spaces" do
      expect(example.parse("Paco")).to eq("Paco")
    end

    it "raises an error" do
      expect { example.parse("!") }.to raise_error(Paco::ParseError)
    end
  end
end
