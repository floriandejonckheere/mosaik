# frozen_string_literal: true
# typed: true

RSpec.describe MOSAIK::Constant do
  subject(:constant) { build(:constant, name: "Name") }

  it "has a name" do
    expect(constant.name).to eq "Name"
  end

  it "has an empty hash of methods" do
    expect(constant.methods).to eq({})
  end

  describe "#hash" do
    it "returns the hash of the name" do
      expect(constant.hash).to eq constant.name.hash
    end
  end

  describe "#==" do
    it "returns true when the name is the same" do
      other = build(:constant, name: constant.name)

      expect(constant).to eq(other)
    end

    it "returns false when the name is different" do
      other = build(:constant, name: "Other")

      expect(constant).not_to eq(other)
    end
  end
end
