# frozen_string_literal: true
# typed: true

RSpec.describe MOSAIK::Constant do
  subject(:constant) { described_class.new(name) }

  let(:name) { "MOSAIK::Constant" }

  it "has a name" do
    expect(constant.name).to eq(name)
  end

  it "has an empty array of methods" do
    expect(constant.methods).to eq([])
  end
end
