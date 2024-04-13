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

  describe "#add_edge" do
    context "when the graph is directed" do
      subject(:graph) { build(:graph, directed: true) }

      it "adds a directed edge" do
        graph.add_vertex("vertex1")
        graph.add_vertex("vertex2")
        graph.add_edge("vertex1", "vertex2")

        expect(graph.find_vertex("vertex1").edges.keys).to eq ["vertex2"]
        expect(graph.find_vertex("vertex2").edges).to be_empty
      end

      it "sets the attributes" do
        graph.add_vertex("vertex1")
        graph.add_vertex("vertex2")
        graph.add_edge("vertex1", "vertex2", key: "value")

        expect(graph.find_vertex("vertex1").edges["vertex2"].attributes).to eq key: "value"
      end

      context "when the edge already exists" do
        it "does not add a directed edge multiple times" do
          graph.add_vertex("vertex1")
          graph.add_vertex("vertex2")
          graph.add_edge("vertex1", "vertex2")
          graph.add_edge("vertex1", "vertex2")
          graph.add_edge("vertex1", "vertex2")

          expect(graph.find_vertex("vertex1").edges.keys).to eq ["vertex2"]
          expect(graph.find_vertex("vertex2").edges.keys).to be_empty
        end

        it "merges the attributes" do
          graph.add_vertex("vertex1")
          graph.add_vertex("vertex2")
          graph.add_edge("vertex1", "vertex2", key: "value")
          graph.add_edge("vertex1", "vertex2", value: "key")
          graph.add_edge("vertex1", "vertex2", key: "key")

          expect(graph.find_vertex("vertex1").edges["vertex2"].attributes).to eq key: "key", value: "key"
        end
      end
    end

    context "when the graph is undirected" do
      subject(:graph) { build(:graph, directed: false) }

      it "adds an undirected edge" do
        graph.add_vertex("vertex1")
        graph.add_vertex("vertex2")
        graph.add_edge("vertex1", "vertex2")

        expect(graph.find_vertex("vertex1").edges.keys).to eq ["vertex2"]
        expect(graph.find_vertex("vertex2").edges.keys).to eq ["vertex1"]

        expect(graph.find_vertex("vertex1").edges["vertex2"].object_id).to eq graph.find_vertex("vertex2").edges["vertex1"].object_id
      end

      it "sets the attributes" do
        graph.add_vertex("vertex1")
        graph.add_vertex("vertex2")
        graph.add_edge("vertex1", "vertex2", key: "value")

        expect(graph.find_vertex("vertex1").edges["vertex2"].attributes).to eq key: "value"
        expect(graph.find_vertex("vertex2").edges["vertex1"].attributes).to eq key: "value"
      end

      context "when the edge already exists" do
        it "adds an undirected edge multiple times" do
          graph.add_vertex("vertex1")
          graph.add_vertex("vertex2")
          graph.add_edge("vertex1", "vertex2")
          graph.add_edge("vertex1", "vertex2")

          expect(graph.find_vertex("vertex1").edges.keys).to eq ["vertex2"]
          expect(graph.find_vertex("vertex2").edges.keys).to eq ["vertex1"]

          expect(graph.find_vertex("vertex1").edges["vertex2"].object_id).to eq graph.find_vertex("vertex2").edges["vertex1"].object_id
        end

        it "merges the attributes" do
          graph.add_vertex("vertex1")
          graph.add_vertex("vertex2")
          graph.add_edge("vertex1", "vertex2", key: "value")
          graph.add_edge("vertex1", "vertex2", value: "key")
          graph.add_edge("vertex1", "vertex2", key: "key")

          expect(graph.find_vertex("vertex1").edges["vertex2"].attributes).to eq key: "key", value: "key"
          expect(graph.find_vertex("vertex2").edges["vertex1"].attributes).to eq key: "key", value: "key"
        end
      end
    end
  end

  describe "#find_edge" do
    it "returns nil when the edge does not exist" do
      graph.add_vertex("vertex1")
      graph.add_vertex("vertex2")

      expect(graph.find_edge("vertex1", "vertex2")).to be_nil
    end

    it "finds an edge" do
      graph.add_vertex("vertex1")
      graph.add_vertex("vertex2")

      graph.add_edge("vertex1", "vertex2", weight: 3)

      expect(graph.find_edge("vertex1", "vertex2").attributes[:weight]).to eq 3
    end
  end

  describe "#find_or_add_edge" do
    it "returns a new edge when the edge does not exist" do
      graph.add_vertex("vertex1")
      graph.add_vertex("vertex2")

      expect(graph.find_or_add_edge("vertex1", "vertex2").attributes).to be_empty
    end

    it "finds an edge" do
      graph.add_vertex("vertex1")
      graph.add_vertex("vertex2")

      graph.add_edge("vertex1", "vertex2", weight: 3)

      expect(graph.find_or_add_edge("vertex1", "vertex2").attributes[:weight]).to eq 3
    end
  end

  describe "#remove_edge" do
    context "when the graph is directed" do
      subject(:graph) { build(:graph, directed: true) }

      it "removes a directed edge" do
        graph.add_vertex("vertex1")
        graph.add_vertex("vertex2")
        graph.add_edge("vertex1", "vertex2")

        graph.remove_edge("vertex1", "vertex2")

        expect(graph.find_vertex("vertex1").edges).to be_empty
      end

      it "does not remove a non-existing directed edge" do
        graph.add_vertex("vertex1")
        graph.add_vertex("vertex2")

        graph.remove_edge("vertex1", "vertex2")

        expect(graph.find_vertex("vertex1").edges).to be_empty
      end
    end

    context "when the graph is undirected" do
      subject(:graph) { build(:graph, directed: false) }

      it "removes an undirected edge" do
        graph.add_vertex("vertex1")
        graph.add_vertex("vertex2")
        graph.add_edge("vertex1", "vertex2")

        graph.remove_edge("vertex1", "vertex2")

        expect(graph.find_vertex("vertex1").edges).to be_empty
      end

      it "does not remove a non-existing directed edge" do
        graph.add_vertex("vertex1")
        graph.add_vertex("vertex2")

        graph.remove_edge("vertex1", "vertex2")

        expect(graph.find_vertex("vertex1").edges).to be_empty
      end
    end
  end

  describe "#add_cluster" do
    it "adds a cluster" do
      graph.add_cluster("cluster")

      expect(graph.clusters).not_to be_empty
    end
  end

  describe "#find_cluster" do
    it "finds a cluster" do
      graph.add_cluster("cluster")

      cluster = graph.find_cluster("cluster")

      expect(cluster).to be_a MOSAIK::Graph::Cluster
      expect(cluster.id).to eq "cluster"
    end
  end

  describe "#find_or_add_cluster" do
    it "finds a cluster" do
      graph.add_cluster("cluster")

      cluster = graph.find_or_add_cluster("cluster")

      expect(cluster).to be_a MOSAIK::Graph::Cluster
      expect(cluster.id).to eq "cluster"
    end

    it "adds a cluster" do
      cluster = graph.find_or_add_cluster("cluster")

      expect(cluster).to be_a MOSAIK::Graph::Cluster
      expect(cluster.id).to eq "cluster"
    end
  end

  describe "#total_weight" do
    it "returns the total weight of the graph" do
      graph.add_vertex("vertex1")
      graph.add_vertex("vertex2")
      graph.add_vertex("vertex3")

      graph.add_edge("vertex1", "vertex2")
      graph.add_edge("vertex2", "vertex3", weight: 1.0)
      graph.add_edge("vertex3", "vertex1", weight: 2.5)

      expect(graph.total_weight).to eq 3.5
    end
  end

  describe "#to_dot" do
    context "when the graph is directed" do
      subject(:graph) { build(:graph, directed: true) }

      it "returns the graph in DOT format" do
        graph.add_vertex("vertex1")
        graph.add_vertex("vertex2")
        graph.add_vertex("vertex3")
        graph.add_edge("vertex1", "vertex2")
        graph.add_edge("vertex2", "vertex3", foo: "bar", baz: "bat")

        expect(graph.to_dot).to eq <<~DOT
          digraph {
            "vertex1" -> "vertex2"
            "vertex2" -> "vertex3" [label="foo: bar, baz: bat"]
          }
        DOT
      end
    end

    context "when the graph is undirected" do
      subject(:graph) { build(:graph, directed: false) }

      it "returns the graph in DOT format" do
        graph.add_vertex("vertex1")
        graph.add_vertex("vertex2")
        graph.add_vertex("vertex3")
        graph.add_edge("vertex1", "vertex2")
        graph.add_edge("vertex2", "vertex3", foo: "bar", baz: "bat")

        expect(graph.to_dot).to eq <<~DOT
          graph {
            "vertex1" -- "vertex2"
            "vertex2" -- "vertex3" [label="foo: bar, baz: bat"]
          }
        DOT
      end
    end

    context "when the graph has clusters" do
      it "returns the graph in DOT format" do
        v1 = graph.add_vertex("vertex1")
        v2 = graph.add_vertex("vertex2")
        v3 = graph.add_vertex("vertex3")
        v4 = graph.add_vertex("vertex4")
        graph.add_vertex("vertex5")
        graph.add_edge("vertex1", "vertex2")
        graph.add_edge("vertex2", "vertex3", foo: "bar", baz: "bat")
        graph.add_edge("vertex1", "vertex3")
        graph.add_edge("vertex1", "vertex4")
        graph.add_edge("vertex5", "vertex5")

        c1 = graph.add_cluster("cluster1")
        c1.add_vertex(v1)
        c1.add_vertex(v2)
        c1.add_vertex(v3)

        c2 = graph.add_cluster("cluster2")
        c2.add_vertex(v4)

        graph.add_cluster("cluster3")

        expect(graph.to_dot).to eq <<~DOT
          digraph {
            subgraph "cluster1" {
              cluster = true
              label = "cluster1"
              color = "lightblue"
              node [shape=circle, style=filled, fillcolor=lightblue]
              "vertex1"
              "vertex2"
              "vertex3"
            }
            subgraph "cluster2" {
              cluster = true
              label = "cluster2"
              color = "lightblue"
              node [shape=circle, style=filled, fillcolor=lightblue]
              "vertex4"
            }
            subgraph "cluster3" {
              cluster = true
              label = "cluster3"
              color = "lightblue"
              node [shape=circle, style=filled, fillcolor=lightblue]
            }
            "vertex1" -> "vertex2"
            "vertex1" -> "vertex3"
            "vertex1" -> "vertex4"
            "vertex2" -> "vertex3" [label="foo: bar, baz: bat"]
            "vertex5" -> "vertex5"
          }
        DOT
      end
    end
  end

  describe "#to_csv" do
    context "when the graph is directed" do
      subject(:graph) { build(:graph, directed: true) }

      it "returns an adjacency list" do
        graph.add_vertex("vertex1")
        graph.add_vertex("vertex2")
        graph.add_vertex("vertex3")
        graph.add_edge("vertex1", "vertex2")
        graph.add_edge("vertex2", "vertex3", method: "method", weight: 1.0)

        expect(graph.to_csv).to eq <<~CSV
          from,to,method,weight
          vertex1,vertex2,,
          vertex2,vertex3,method,1.0
        CSV
      end
    end

    context "when the graph is undirected" do
      subject(:graph) { build(:graph, directed: false) }

      it "returns an adjacency list" do
        graph.add_vertex("vertex1")
        graph.add_vertex("vertex2")
        graph.add_vertex("vertex3")
        graph.add_edge("vertex1", "vertex2")
        graph.add_edge("vertex2", "vertex3", method: "method", weight: 1.0)

        expect(graph.to_csv).to eq <<~CSV
          from,to,method,weight
          vertex1,vertex2,,
          vertex2,vertex3,method,1.0
        CSV
      end
    end

    context "when the graph has clusters" do
      it "returns the graph in DOT format" do
        v1 = graph.add_vertex("vertex1")
        v2 = graph.add_vertex("vertex2")
        v3 = graph.add_vertex("vertex3")
        graph.add_edge("vertex1", "vertex2")
        graph.add_edge("vertex2", "vertex3", method: "method", weight: 1.0)

        c1 = graph.add_cluster("cluster1")
        c1.add_vertex(v1)
        c1.add_vertex(v2)

        c2 = graph.add_cluster("cluster2")
        c2.add_vertex(v3)

        graph.add_cluster("cluster3")

        expect(graph.to_csv).to eq <<~CSV
          from,to,method,weight
          vertex1,vertex2,,
          vertex2,vertex3,method,1.0
          --
          vertex,cluster
          vertex1,cluster1
          vertex2,cluster1
          vertex3,cluster2
        CSV
      end
    end
  end

  describe ".from_csv" do
    context "when the graph is undirected" do
      it "creates a graph from an adjacency list" do
        csv = <<~CSV
          from,to,method,weight
          vertex1,vertex2,,
          vertex2,vertex3,method,1.0
        CSV

        graph = described_class.from_csv(csv, directed: false)

        expect(graph.directed).to be false

        expect(graph.vertices.keys).to eq ["vertex1", "vertex2", "vertex3"]
        expect(graph.find_vertex("vertex1").edges.keys).to eq ["vertex2"]
        expect(graph.find_vertex("vertex2").edges.keys).to eq ["vertex1", "vertex3"]
        expect(graph.find_vertex("vertex2").edges["vertex3"].attributes).to eq method: "method", weight: 1.0
        expect(graph.find_vertex("vertex3").edges.keys).to eq ["vertex2"]
        expect(graph.find_vertex("vertex3").edges["vertex2"].attributes).to eq method: "method", weight: 1.0

        expect(graph.find_vertex("vertex2").edges["vertex3"].object_id).to eq graph.find_vertex("vertex3").edges["vertex2"].object_id
      end
    end

    context "when the graph is directed" do
      it "creates a graph from an adjacency list" do
        csv = <<~CSV
          from,to,method,weight
          vertex1,vertex2,
          vertex2,vertex3,method,1.0
        CSV

        graph = described_class.from_csv(csv, directed: true)

        expect(graph.directed).to be true

        expect(graph.vertices.keys).to eq ["vertex1", "vertex2", "vertex3"]
        expect(graph.find_vertex("vertex1").edges.keys).to eq ["vertex2"]
        expect(graph.find_vertex("vertex2").edges["vertex3"].attributes).to eq method: "method", weight: 1.0
        expect(graph.find_vertex("vertex3").edges).to be_empty
      end
    end

    context "when the graph has clusters" do
      it "returns the graph in DOT format" do
        csv = <<~CSV
          from,to,method,weight
          vertex1,vertex2,,
          vertex2,vertex3,method,1.0
          --
          vertex,cluster
          vertex1,cluster1
          vertex2,cluster1
          vertex3,cluster2
        CSV

        graph = described_class.from_csv(csv, directed: true)

        expect(graph.directed).to be true

        expect(graph.vertices.keys).to eq ["vertex1", "vertex2", "vertex3"]
        expect(graph.find_vertex("vertex1").edges.keys).to eq ["vertex2"]
        expect(graph.find_vertex("vertex2").edges["vertex3"].attributes).to eq method: "method", weight: 1.0
        expect(graph.find_vertex("vertex3").edges).to be_empty

        expect(graph.clusters.keys).to eq ["cluster1", "cluster2"]
        expect(graph.find_cluster("cluster1").vertices.map(&:id)).to eq ["vertex1", "vertex2"]
        expect(graph.find_cluster("cluster2").vertices.map(&:id)).to eq ["vertex3"]
      end
    end
  end
end
