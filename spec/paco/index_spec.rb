require "spec_helper"

RSpec.describe Paco::Index do
  subject(:index) { described_class }

  let(:input) { "1\n2\n\n3\nPaco" }

  it "returns index", :aggregate_failures do
    expect(index.calculate(input: input, pos: 0)).to eq(Paco::Index.new(0, 1, 1))
    expect(index.calculate(input: input, pos: 1)).to eq(Paco::Index.new(1, 1, 2))
    expect(index.calculate(input: input, pos: 2)).to eq(Paco::Index.new(2, 2, 1))
    expect(index.calculate(input: input, pos: 10)).to eq(Paco::Index.new(10, 5, 4))
  end

  it "returns start position when empty string" do
    expect(index.calculate(input: "", pos: 0)).to eq(Paco::Index.new(0, 1, 1))
  end

  it "raises an error when pos < 0" do
    expect { index.calculate(input: input, pos: -1) }.to raise_error(ArgumentError)
  end

  it "raises an error when pos > input length" do
    expect { index.calculate(input: input, pos: 1000) }.to raise_error(ArgumentError)
  end
end
