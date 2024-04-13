# frozen_string_literal: true

RSpec.describe MOSAIK::Graph::Cluster do
  subject(:cluster) { build(:cluster) }

  describe "#attributes" do
    it "returns the attributes" do
      expect(cluster.attributes).to eq key: "value"
    end
  end

  describe "#add_vertex" do
    it "adds a vertex to the cluster" do
      vertex = build(:vertex)
      cluster.add_vertex(vertex)

      expect(cluster.vertices).to include vertex
    end

    it "does not add the same vertex twice" do
      vertex = build(:vertex)
      cluster.add_vertex(vertex)
      cluster.add_vertex(vertex)

      expect(cluster.vertices.count).to eq 1
    end
  end

  describe "#remove_vertex" do
    it "removes a vertex from the cluster" do
      vertex = build(:vertex)
      cluster.add_vertex(vertex)
      cluster.remove_vertex(vertex)

      expect(cluster.vertices).not_to include vertex
    end
  end
end
