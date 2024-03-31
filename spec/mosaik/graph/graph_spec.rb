# frozen_string_literal: true

RSpec.describe MOSAIK::Graph::Graph do
  subject(:graph) { build(:graph) }

  describe "#add_vertex" do
    it "adds a vertex" do
      graph.add_vertex("vertex")

      expect(graph.vertices).not_to be_empty
    end

    it "adds a vertex with attributes" do
      graph.add_vertex("vertex", key: "value")

      expect(graph.find_vertex("vertex").attributes).to eq key: "value"
    end
  end

  describe "#add_edge, #add_directed_edge" do
    it "adds a directed edge" do
      graph.add_vertex("vertex1")
      graph.add_vertex("vertex2")
      graph.add_directed_edge("vertex1", "vertex2")

      expect(graph.find_vertex("vertex1").edges.keys).to eq ["vertex2"]
    end

    it "does not add a directed edge twice" do
      graph.add_vertex("vertex1")
      graph.add_vertex("vertex2")
      graph.add_directed_edge("vertex1", "vertex2")
      graph.add_directed_edge("vertex1", "vertex2")

      expect(graph.find_vertex("vertex1").edges.keys).to eq ["vertex2"]
    end

    describe "weighted" do
      it "adds a directed weighted edge" do
        graph.add_vertex("vertex1")
        graph.add_vertex("vertex2")
        graph.add_directed_edge("vertex1", "vertex2", 5)

        expect(graph.find_vertex("vertex1").edges.keys).to eq ["vertex2"]
        expect(graph.find_vertex("vertex1").edges["vertex2"]).to eq 5
      end

      it "overrides a directed weighted edge" do
        graph.add_vertex("vertex1")
        graph.add_vertex("vertex2")
        graph.add_directed_edge("vertex1", "vertex2", 5)
        graph.add_directed_edge("vertex1", "vertex2", 10)

        expect(graph.find_vertex("vertex1").edges.keys).to eq ["vertex2"]
        expect(graph.find_vertex("vertex1").edges["vertex2"]).to eq 10
      end
    end
  end

  describe "#add_undirected_edge" do
    it "adds an undirected edge" do
      graph.add_vertex("vertex1")
      graph.add_vertex("vertex2")
      graph.add_undirected_edge("vertex1", "vertex2")

      expect(graph.find_vertex("vertex1").edges.keys).to eq ["vertex2"]
    end

    it "does not add an undirected edge twice" do
      graph.add_vertex("vertex1")
      graph.add_vertex("vertex2")
      graph.add_undirected_edge("vertex1", "vertex2")
      graph.add_undirected_edge("vertex1", "vertex2")

      expect(graph.find_vertex("vertex1").edges.keys).to eq ["vertex2"]
    end

    describe "weighted" do
      it "adds an undirected weighted edge" do
        graph.add_vertex("vertex1")
        graph.add_vertex("vertex2")
        graph.add_undirected_edge("vertex1", "vertex2", 5)

        expect(graph.find_vertex("vertex1").edges.keys).to eq ["vertex2"]
        expect(graph.find_vertex("vertex1").edges["vertex2"]).to eq 5
      end

      it "overrides an undirected weighted edge" do
        graph.add_vertex("vertex1")
        graph.add_vertex("vertex2")
        graph.add_undirected_edge("vertex1", "vertex2", 5)
        graph.add_undirected_edge("vertex1", "vertex2", 10)

        expect(graph.find_vertex("vertex1").edges.keys).to eq ["vertex2"]
        expect(graph.find_vertex("vertex1").edges["vertex2"]).to eq 10
      end
    end
  end

  describe "#remove_edge, #remove_directed_edge" do
    it "removes a directed edge" do
      graph.add_vertex("vertex1")
      graph.add_vertex("vertex2")
      graph.add_directed_edge("vertex1", "vertex2")

      graph.remove_directed_edge("vertex1", "vertex2")

      expect(graph.find_vertex("vertex1").edges).to be_empty
    end

    it "does not remove a non-existing directed edge" do
      graph.add_vertex("vertex1")
      graph.add_vertex("vertex2")

      graph.remove_directed_edge("vertex1", "vertex2")

      expect(graph.find_vertex("vertex1").edges).to be_empty
    end

    describe "weighted" do
      it "removes a directed weighted edge" do
        graph.add_vertex("vertex1")
        graph.add_vertex("vertex2")
        graph.add_directed_edge("vertex1", "vertex2", 5)

        graph.remove_directed_edge("vertex1", "vertex2")

        expect(graph.find_vertex("vertex1").edges).to be_empty
      end

      it "does not remove a non-existing directed weighted edge" do
        graph.add_vertex("vertex1")
        graph.add_vertex("vertex2")

        graph.remove_directed_edge("vertex1", "vertex2")

        expect(graph.find_vertex("vertex1").edges).to be_empty
      end
    end
  end

  describe "#remove_undirected_edge" do
    it "removes an undirected edge" do
      graph.add_vertex("vertex1")
      graph.add_vertex("vertex2")
      graph.add_undirected_edge("vertex1", "vertex2")

      graph.remove_undirected_edge("vertex1", "vertex2")

      expect(graph.find_vertex("vertex1").edges).to be_empty
    end

    it "does not remove a non-existing directed edge" do
      graph.add_vertex("vertex1")
      graph.add_vertex("vertex2")

      graph.remove_undirected_edge("vertex1", "vertex2")

      expect(graph.find_vertex("vertex1").edges).to be_empty
    end

    describe "weighted" do
      it "removes a directed weighted edge" do
        graph.add_vertex("vertex1")
        graph.add_vertex("vertex2")
        graph.add_directed_edge("vertex1", "vertex2", 5)

        graph.remove_directed_edge("vertex1", "vertex2")

        expect(graph.find_vertex("vertex1").edges).to be_empty
      end

      it "does not remove a non-existing directed weighted edge" do
        graph.add_vertex("vertex1")
        graph.add_vertex("vertex2")

        graph.remove_directed_edge("vertex1", "vertex2")

        expect(graph.find_vertex("vertex1").edges).to be_empty
      end
    end
  end

  describe "#find_vertex" do
    it "finds a vertex" do
      graph.add_vertex("vertex")

      vertex = graph.find_vertex("vertex")

      expect(vertex).to be_a MOSAIK::Graph::Vertex
      expect(vertex.id).to eq "vertex"
    end
  end

  describe "#find_or_add_vertex" do
    it "finds a vertex" do
      graph.add_vertex("vertex")

      vertex = graph.find_or_add_vertex("vertex")

      expect(vertex).to be_a MOSAIK::Graph::Vertex
      expect(vertex.id).to eq "vertex"
    end

    it "adds a vertex" do
      vertex = graph.find_or_add_vertex("vertex")

      expect(vertex).to be_a MOSAIK::Graph::Vertex
      expect(vertex.id).to eq "vertex"
    end
  end

  describe "#remove_vertex" do
    it "removes a vertex" do
      graph.add_vertex("vertex")

      graph.remove_vertex("vertex")

      expect(graph.vertices).to be_empty
    end
  end

  describe "#tsort" do
    it "topologically sorts the vertices" do
      graph.add_vertex("vertex1")
      graph.add_vertex("vertex2")
      graph.add_vertex("vertex3")

      expect(graph.tsort.map(&:id)).to eq ["vertex1", "vertex2", "vertex3"]

      graph.add_directed_edge("vertex1", "vertex2")
      graph.add_directed_edge("vertex2", "vertex3")

      expect(graph.tsort.map(&:id)).to eq ["vertex3", "vertex2", "vertex1"]
    end
  end
end
