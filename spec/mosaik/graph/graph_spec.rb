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

  describe "#add_edge" do
    it "adds an edge" do
      vertex1 = build(:vertex, value: "vertex1")
      vertex2 = build(:vertex, value: "vertex2")

      graph.add_vertex(vertex1)
      graph.add_vertex(vertex2)
      graph.add_edge(vertex1, vertex2)

      expect(graph.find_vertex("vertex1").edges.keys).to eq ["vertex2"]
    end

    it "does not add an edge twice" do
      vertex1 = build(:vertex, value: "vertex1")
      vertex2 = build(:vertex, value: "vertex2")

      graph.add_vertex(vertex1)
      graph.add_vertex(vertex2)
      graph.add_edge(vertex1, vertex2)
      graph.add_edge(vertex1, vertex2)

      expect(graph.find_vertex("vertex1").edges.keys).to eq ["vertex2"]
    end

    describe "weighted" do
      it "adds a weighted edge" do
        vertex1 = build(:vertex, value: "vertex1")
        vertex2 = build(:vertex, value: "vertex2")

        graph.add_vertex(vertex1)
        graph.add_vertex(vertex2)
        graph.add_edge(vertex1, vertex2, 5)

        expect(graph.find_vertex("vertex1").edges.keys).to eq ["vertex2"]
        expect(graph.find_vertex("vertex1").edges["vertex2"]).to eq 5
      end

      it "overrides a weighted edge" do
        vertex1 = build(:vertex, value: "vertex1")
        vertex2 = build(:vertex, value: "vertex2")

        graph.add_vertex(vertex1)
        graph.add_vertex(vertex2)
        graph.add_edge(vertex1, vertex2, 5)
        graph.add_edge(vertex1, vertex2, 10)

        expect(graph.find_vertex("vertex1").edges.keys).to eq ["vertex2"]
        expect(graph.find_vertex("vertex1").edges["vertex2"]).to eq 10
      end
    end
  end

  describe "#remove_edge" do
    it "removes an edge" do
      vertex1 = build(:vertex, value: "vertex1")
      vertex2 = build(:vertex, value: "vertex2")

      graph.add_vertex(vertex1)
      graph.add_vertex(vertex2)
      graph.add_edge(vertex1, vertex2)

      graph.remove_edge(vertex1, vertex2)

      expect(graph.find_vertex("vertex1").edges).to be_empty
    end

    it "does not remove a non-existing edge" do
      vertex1 = build(:vertex, value: "vertex1")
      vertex2 = build(:vertex, value: "vertex2")

      graph.add_vertex(vertex1)
      graph.add_vertex(vertex2)

      graph.remove_edge(vertex1, vertex2)

      expect(graph.find_vertex("vertex1").edges).to be_empty
    end

    describe "weighted" do
      it "removes a weighted edge" do
        vertex1 = build(:vertex, value: "vertex1")
        vertex2 = build(:vertex, value: "vertex2")

        graph.add_vertex(vertex1)
        graph.add_vertex(vertex2)
        graph.add_edge(vertex1, vertex2, 5)

        graph.remove_edge(vertex1, vertex2)

        expect(graph.find_vertex("vertex1").edges).to be_empty
      end

      it "does not remove a non-existing weighted edge" do
        vertex1 = build(:vertex, value: "vertex1")
        vertex2 = build(:vertex, value: "vertex2")

        graph.add_vertex(vertex1)
        graph.add_vertex(vertex2)

        graph.remove_edge(vertex1, vertex2)

        expect(graph.find_vertex("vertex1").edges).to be_empty
      end
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
