# frozen_string_literal: true

RSpec.describe MOSAIK::Graph::Graph do
  subject(:graph) { build(:graph) }

  describe "#add_vertex" do
    it "adds a vertex" do
      vertex = build(:vertex, value: "vertex")

      graph.add_vertex(vertex)

      expect(graph.vertices).not_to be_empty
    end
  end

  describe "#find_vertex" do
    it "finds a vertex" do
      graph.add_vertex(build(:vertex, value: "address"))

      vertex = graph.find_vertex("address")

      expect(vertex).to be_a MOSAIK::Graph::Vertex
      expect(vertex.value).to eq "address"
    end
  end

  describe "#remove_vertex" do
    it "removes a vertex" do
      graph.add_vertex(build(:vertex, value: "address"))

      vertex = graph.find_vertex("address")

      graph.remove_vertex(vertex)

      expect(graph.vertices).to be_empty
    end
  end
end
