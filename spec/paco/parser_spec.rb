# frozen_string_literal: true

require "spec_helper"

RSpec.describe Paco::Parser, :include_combinators do
  let(:parser) { string("Paco") }

  describe "#parse" do
    it "parses string" do
      expect(string("Paco").parse("Paco")).to eq("Paco")
    end

    it "parses Paco::Context" do
      context = Paco::Context.new("Paco")
      expect(string("Paco").parse(context)).to eq("Paco")
    end
  end

  describe "#or" do
    let(:example) { failed("msg").or(string("Paco")) }

    it "returns passed parser result" do
      expect(example.parse("Paco")).to eq("Paco")
    end

    it "raises an error when no parsers passed" do
      expect { example.parse("paco") }.to raise_error(Paco::ParseError)
    end
  end

  describe "#skip" do
    let(:example) { string("Pa").skip(string("co")) }

    it "returns left parser result" do
      expect(example.parse("Paco")).to eq("Pa")
    end

    it "raises an error when no parsers passed" do
      expect { example.parse("paco") }.to raise_error(Paco::ParseError)
    end
  end

  describe "#next" do
    let(:example) { string("Pa").next(string("co")) }

    it "returns right parser result" do
      expect(example.parse("Paco")).to eq("co")
    end

    it "raises an error when no parsers passed" do
      expect { example.parse("paco") }.to raise_error(Paco::ParseError)
    end
  end

  describe "#fmap" do
    let(:example) { string("Paco").fmap(&:upcase) }

    it "returns block result" do
      expect(example.parse("Paco")).to eq("PACO")
    end
  end

  describe "#bind" do
    let(:example) { letters.bind { |res| ws.next(string(res.upcase)) } }

    it "returns parser result" do
      expect(example.parse("Paco PACO")).to eq("PACO")
    end
  end

  describe "#many" do
    let(:example) { digit.many.skip(remainder) }

    it "returns parsed result" do
      expect(example.parse("123")).to eq(%w[1 2 3])
    end

    it "returns empty array when parser fails" do
      expect(example.parse("Paco")).to eq([])
    end
  end

  describe "#result" do
    let(:example) { string("Paco").result(true) }

    it "returns the result" do
      expect(example.parse("Paco")).to eq(true)
    end

    it "raises an error when no parsers passed" do
      expect { example.parse("paco") }.to raise_error(Paco::ParseError)
    end
  end

  describe "#fallback" do
    let(:example) { string("Paco").fallback("<null>").skip(remainder) }

    it "returns parsers result" do
      expect(example.parse("Paco")).to eq("Paco")
    end

    it "returns fallback when parser fails" do
      expect(example.parse("paco")).to eq("<null>")
    end
  end

  describe "#trim" do
    let(:example) { letters.trim(string(" ")) }

    it "returns parser result" do
      expect(example.parse(" Paco ")).to eq("Paco")
    end

    it "raises an error when wrapped parser fails" do
      expect { example.parse(" Пако ") }.to raise_error(Paco::ParseError)
    end

    it "raises an error when wrapping parser fails" do
      expect { example.parse("  Paco ") }.to raise_error(Paco::ParseError)
    end
  end

  describe "#wrap" do
    let(:example) { letters.wrap(string("{"), string("}")) }

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

  describe "#not_followed_by" do
    let(:example) { string("a").not_followed_by(string("b")).skip(remainder) }

    it "returns result of the parser" do
      expect(example.parse("ac")).to eq("a")
    end

    it "raises an error" do
      expect { example.parse("ab") }.to raise_error(Paco::ParseError)
    end
  end

  describe "#join" do
    it "returns joined result of the parser" do
      expect(letter.many.join.parse("abc")).to eq("abc")
    end

    it "returns joined result of the parser" do
      expect(letter.many.join(",").parse("abc")).to eq("a,b,c")
    end
  end

  describe "#times" do
    let(:example) { digit.times(2).skip(remainder) }

    it "returns array of results of the parser" do
      expect(example.parse("1111")).to eq(%w[1 1])
    end

    it "raises an error" do
      expect { example.parse("1a") }.to raise_error(Paco::ParseError)
    end

    context "with min and max are specified" do
      let(:example) { digit.times(2, 3).skip(remainder) }

      it "returns array of results of the parser" do
        expect(example.parse("1111")).to eq(%w[1 1 1])
      end

      it "returns array of results of the parser" do
        expect(example.parse("11a")).to eq(%w[1 1])
      end

      it "raises an error" do
        expect { example.parse("1a") }.to raise_error(Paco::ParseError)
      end
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
    let(:example) { digit.at_least(2).skip(remainder) }

    it "returns array of results of the parser" do
      expect(example.parse("111a")).to eq(%w[1 1 1])
    end

    it "raises an error" do
      expect { example.parse("1a") }.to raise_error(Paco::ParseError)
    end
  end

  describe "#at_most" do
    let(:example) { digit.at_most(2).skip(remainder) }

    it "returns array of results of the parser" do
      expect(example.parse("1111")).to eq(%w[1 1])
    end

    it "returns array of results of the parser" do
      expect(example.parse("Paco")).to eq(%w[])
    end
  end
end
