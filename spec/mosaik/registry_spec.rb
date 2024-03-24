# frozen_string_literal: true

RSpec.describe MOSAIK::Registry do
  subject(:registry) { described_class.new }

  it "has an empty array of constants" do
    expect(registry.constants).to eq({})
  end
end
