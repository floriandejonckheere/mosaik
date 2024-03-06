# frozen_string_literal: true

RSpec.describe MOSAIK::Version do
  it "has a version number" do
    expect(MOSAIK::VERSION).not_to be_nil
  end
end
