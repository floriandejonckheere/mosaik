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
      expect(graph.find_vertex("vertex2").edges).to be_empty
    end

    it "sets the attributes" do
      graph.add_vertex("vertex1")
      graph.add_vertex("vertex2")
      graph.add_directed_edge("vertex1", "vertex2", key: "value")

      expect(graph.find_vertex("vertex1").edges["vertex2"].attributes).to eq key: "value"
    end

    context "when the edge already exists" do
      it "does not add a directed edge multiple times" do
        graph.add_vertex("vertex1")
        graph.add_vertex("vertex2")
        graph.add_directed_edge("vertex1", "vertex2")
        graph.add_directed_edge("vertex1", "vertex2")
        graph.add_directed_edge("vertex1", "vertex2")

        expect(graph.find_vertex("vertex1").edges.keys).to eq ["vertex2"]
        expect(graph.find_vertex("vertex2").edges.keys).to be_empty
      end

      it "merges the attributes" do
        graph.add_vertex("vertex1")
        graph.add_vertex("vertex2")
        graph.add_directed_edge("vertex1", "vertex2", key: "value")
        graph.add_directed_edge("vertex1", "vertex2", value: "key")
        graph.add_directed_edge("vertex1", "vertex2", key: "key")

        expect(graph.find_vertex("vertex1").edges["vertex2"].attributes).to eq key: "key", value: "key"
      end
    end
  end

  describe "#add_undirected_edge" do
    it "adds an undirected edge" do
      graph.add_vertex("vertex1")
      graph.add_vertex("vertex2")
      graph.add_undirected_edge("vertex1", "vertex2")

      expect(graph.find_vertex("vertex1").edges.keys).to eq ["vertex2"]
      expect(graph.find_vertex("vertex2").edges.keys).to eq ["vertex1"]
    end

    it "sets the attributes" do
      graph.add_vertex("vertex1")
      graph.add_vertex("vertex2")
      graph.add_undirected_edge("vertex1", "vertex2", key: "value")

      expect(graph.find_vertex("vertex1").edges["vertex2"].attributes).to eq key: "value"
      expect(graph.find_vertex("vertex2").edges["vertex1"].attributes).to eq key: "value"
    end

    context "when the edge already exists" do
      it "adds an undirected edge multiple times" do
        graph.add_vertex("vertex1")
        graph.add_vertex("vertex2")
        graph.add_undirected_edge("vertex1", "vertex2")
        graph.add_undirected_edge("vertex1", "vertex2")

        expect(graph.find_vertex("vertex1").edges.keys).to eq ["vertex2"]
        expect(graph.find_vertex("vertex2").edges.keys).to eq ["vertex1"]
      end

      it "merges the attributes" do
        graph.add_vertex("vertex1")
        graph.add_vertex("vertex2")
        graph.add_undirected_edge("vertex1", "vertex2", key: "value")
        graph.add_undirected_edge("vertex1", "vertex2", value: "key")
        graph.add_undirected_edge("vertex1", "vertex2", key: "key")

        expect(graph.find_vertex("vertex1").edges["vertex2"].attributes).to eq key: "key", value: "key"
        expect(graph.find_vertex("vertex2").edges["vertex1"].attributes).to eq key: "key", value: "key"
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

    it "adds a vertex with attributes" do
      vertex = graph.find_or_add_vertex("vertex", key: "value")

      expect(vertex.attributes).to eq key: "value"
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
