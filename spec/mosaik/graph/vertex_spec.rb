# frozen_string_literal: true

RSpec.describe MOSAIK::Graph::Vertex do
  subject(:vertex) { build(:vertex) }

  describe "#attributes" do
    it "returns the attributes" do
      expect(vertex.attributes).to eq key: "value"
    end
  end

  describe "#add_edge" do
    it "adds an edge" do
      vertex.add_edge("child")

      expect(vertex.edges.keys).to eq ["child"]
    end

    it "adds an edge with attributes" do
      vertex.add_edge("child", key: "value")

      expect(vertex.edges.keys).to eq ["child"]
      expect(vertex.edges["child"].attributes).to eq key: "value"
    end

    it "does not add an edge twice" do
      vertex.add_edge("child")
      vertex.add_edge("child")

      expect(vertex.edges.keys).to eq ["child"]
    end
  end
end
