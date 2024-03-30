# frozen_string_literal: true

RSpec.describe MOSAIK::Graph::Vertex do
  subject(:vertex) { build(:vertex) }

  describe "#add_edge" do
    it "adds an edge" do
      vertex.add_edge("child")

      expect(vertex.edges.keys).to eq ["child"]
    end

    it "does not add an edge twice" do
      vertex.add_edge("child")
      vertex.add_edge("child")

      expect(vertex.edges.keys).to eq ["child"]
    end

    describe "weighted edge" do
      it "adds a weighted edge" do
        vertex.add_edge("child", 5)

        expect(vertex.edges.keys).to eq ["child"]
        expect(vertex.edges["child"]).to eq 5
      end

      it "overrides a weighted edge" do
        vertex.add_edge("child", 5)
        vertex.add_edge("child", 10)

        expect(vertex.edges.keys).to eq ["child"]
        expect(vertex.edges["child"]).to eq 10
      end
    end
  end
end
