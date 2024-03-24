# frozen_string_literal: true
# typed: true

RSpec.describe MOSAIK::Constant do
  subject(:constant) { described_class.new(name) }

  let(:name) { "MOSAIK::Constant" }

  it "has a name" do
    expect(constant.name).to eq(name)
  end

  it "has an empty hash of methods" do
    expect(constant.methods).to eq({})
  end

  describe "#==" do
    it "returns true when the name is the same" do
      other = described_class.new(name)

      expect(constant).to eq(other)
    end

    it "returns false when the name is different" do
      other = described_class.new("other")

      expect(constant).not_to eq(other)
    end
  end
end
