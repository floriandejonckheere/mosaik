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
end
