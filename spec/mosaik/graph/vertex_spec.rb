# frozen_string_literal: true

RSpec.describe MOSAIK::Graph::Vertex do
  subject(:vertex) { build(:vertex) }

  describe "#attributes" do
    it "returns the attributes" do
      expect(vertex.attributes).to eq key: "value"
    end
  end

  describe "#add_edge" do
    it "adds an edge and returns it" do
      edge = vertex.add_edge("child")

      expect(edge).to be_an MOSAIK::Graph::Edge

      expect(vertex.edges.keys).to eq ["child"]
      expect(vertex.edges["child"]).to include edge
    end

    it "sets the attributes" do
      vertex.add_edge("child", key: "value")

      expect(vertex.edges["child"].first.attributes).to eq key: "value"
    end

    context "when the edge already exists" do
      it "adds another edge and returns it" do
        e1 = vertex.add_edge("child")
        e2 = vertex.add_edge("child")
        e3 = vertex.add_edge("child")

        expect(e1).to be_a MOSAIK::Graph::Edge
        expect(e2).to be_a MOSAIK::Graph::Edge
        expect(e3).to be_a MOSAIK::Graph::Edge

        expect(e1).not_to eq e2
        expect(e1).not_to eq e3
        expect(e2).not_to eq e3

        expect(vertex.edges.keys).to eq ["child"]
        expect(vertex.edges["child"]).to contain_exactly e1, e2, e3
      end
    end
  end

  describe "#remove_edge" do
    context "when no edge is given" do
      it "removes all edges" do
        vertex.add_edge("child")
        vertex.add_edge("child")

        vertex.remove_edge("child")

        expect(vertex.edges).to be_empty
      end
    end

    context "when a specific edge is given" do
      it "removes the edge" do
        e1 = vertex.add_edge("child")
        e2 = vertex.add_edge("child")

        vertex.remove_edge("child", e1)

        expect(vertex.edges.keys).to eq ["child"]
        expect(vertex.edges["child"]).to contain_exactly e2
      end
    end
  end
end
