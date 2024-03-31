# frozen_string_literal: true

RSpec.describe MOSAIK::Graph::Edge do
  subject(:edge) { build(:edge) }

  describe "#attributes" do
    it "returns the attributes" do
      expect(edge.attributes).to eq key: "value"
    end
  end
end
