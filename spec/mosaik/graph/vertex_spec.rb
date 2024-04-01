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

    it "sets the attributes" do
      vertex.add_edge("child", key: "value")

      expect(vertex.edges["child"].attributes).to eq key: "value"
    end

    context "when the edge already exists" do
      it "does not add an edge multiple times" do
        vertex.add_edge("child")
        vertex.add_edge("child")
        vertex.add_edge("child")

        expect(vertex.edges.keys).to eq ["child"]
      end

      it "merges the attributes" do
        vertex.add_edge("child", key: "value")
        vertex.add_edge("child", value: "key")
        vertex.add_edge("child", key: "key")

        expect(vertex.edges["child"].attributes).to eq key: "key", value: "key"
      end
    end
  end
end
