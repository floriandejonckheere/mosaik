# frozen_string_literal: true

RSpec.describe MOSAIK::Reference do
  subject(:reference) { build(:reference, constant: build(:constant, name: "Constant"), method: "method") }

  it "has a constant" do
    expect(reference.constant.name).to eq "Constant"
  end

  it "has a method" do
    expect(reference.method).to eq "method"
  end

  describe "#==" do
    it "returns true when the constants and methods are equal" do
      other = build(:reference, constant: reference.constant, method: reference.method)

      expect(reference).to eq other
    end

    it "returns false when the constants are different" do
      other = build(:reference, constant: build(:constant, name: "Other"), method: reference.method)

      expect(reference).not_to eq other
    end

    it "returns false when the methods are different" do
      other = build(:reference, constant: reference.constant, method: "other")

      expect(reference).not_to eq other
    end
  end
end
