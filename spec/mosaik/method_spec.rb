# frozen_string_literal: true
# typed: true

RSpec.describe MOSAIK::Method do
  subject(:method) { described_class.new(name, file, line) }

  let(:name) { "test" }
  let(:file) { "test.rb" }
  let(:line) { 1 }

  it "has a name" do
    expect(method.name).to eq(name)
  end

  it "has a file" do
    expect(method.file).to eq(file)
  end

  it "has a line" do
    expect(method.line).to eq(line)
  end

  it "has an empty array of references" do
    expect(method.references).to eq([])
  end

  describe "#==" do
    it "returns true when the name, file, and line are the same" do
      other = described_class.new(name, file, line)

      expect(method).to eq(other)
    end

    it "returns false when the name is different" do
      other = described_class.new("other", file, line)

      expect(method).not_to eq(other)
    end

    it "returns false when the file is different" do
      other = described_class.new(name, "other.rb", line)

      expect(method).not_to eq(other)
    end

    it "returns false when the line is different" do
      other = described_class.new(name, file, 2)

      expect(method).not_to eq(other)
    end
  end
end
