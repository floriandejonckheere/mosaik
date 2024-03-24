# frozen_string_literal: true
# typed: true

RSpec.describe MOSAIK::Method do
  subject(:method) { build(:method, name: "test", file: "test.rb", line: 5) }

  it "has a name" do
    expect(method.name).to eq "test"
  end

  it "has a file" do
    expect(method.file).to eq "test.rb"
  end

  it "has a line" do
    expect(method.line).to eq 5
  end

  it "has an empty array of references" do
    expect(method.references).to eq([])
  end

  describe "#==" do
    it "returns true when the constant, name, file, and line are the same" do
      other = described_class.new(method.constant, method.name, method.file, method.line)

      expect(method).to eq(other)
    end

    it "returns false when the constant is different" do
      other = described_class.new(build(:constant, name: "Other"), method.name, method.file, method.line)

      expect(method).not_to eq(other)
    end

    it "returns false when the name is different" do
      other = described_class.new(method.constant, "other", method.file, method.line)

      expect(method).not_to eq(other)
    end

    it "returns false when the file is different" do
      other = described_class.new(method.constant, method.name, "other", method.line)

      expect(method).not_to eq(other)
    end

    it "returns false when the line is different" do
      other = described_class.new(method.constant, method.name, method.file, 2)

      expect(method).not_to eq(other)
    end
  end
end
