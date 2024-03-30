# frozen_string_literal: true

RSpec.describe MOSAIK::Graph::Vertex do
  subject(:vertex) { build(:vertex) }

  describe "#add_edge" do
    it "adds an edge" do
      child = build(:vertex, value: "child")

      vertex.add_edge(child)

      expect(vertex.edges.to_a).to eq ["child"]
    end

    it "does not add an edge twice" do
      child = build(:vertex, value: "child")

      vertex.add_edge(child)
      vertex.add_edge(child)

      expect(vertex.edges.to_a).to eq ["child"]
    end
  end
end
