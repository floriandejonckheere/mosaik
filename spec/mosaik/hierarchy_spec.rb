# frozen_string_literal: true

RSpec.describe MOSAIK::Hierarchy do
  subject(:hierarchy) { described_class.new }

  describe "#[]" do
    it "registers and looks up a constant in the hierarchy" do
      # Register constant
      hierarchy["MOSAIK::Constant"]

      # Look up constant
      expect(hierarchy["MOSAIK"]).to eq({ "Constant" => {} })
      expect(hierarchy["MOSAIK::Constant"]).to eq({})
    end
  end
end
