# frozen_string_literal: true

RSpec.describe MOSAIK::Graph::Graph do
  subject(:graph) { build(:graph) }

  describe "#attributes" do
    it "returns the attributes" do
      expect(graph.attributes).to eq key: "value"
    end
  end

  describe "vertices" do
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
  end

  describe "edges" do
    describe "#add_edge" do
      context "when the graph is directed" do
        subject(:graph) { build(:graph, directed: true) }

        it "adds a directed edge and returns it" do
          graph.add_vertex("vertex1")
          graph.add_vertex("vertex2")
          edge = graph.add_edge("vertex1", "vertex2")

          expect(edge).to be_a MOSAIK::Graph::Edge

          expect(graph.find_edges("vertex1", "vertex2")).to contain_exactly edge
          expect(graph.find_edges("vertex2", "vertex1")).to be_empty
        end

        it "sets the attributes" do
          graph.add_vertex("vertex1")
          graph.add_vertex("vertex2")
          edge = graph.add_edge("vertex1", "vertex2", key: "value")

          expect(edge.attributes).to eq key: "value"
        end

        context "when the edge already exists" do
          it "adds another directed edge and returns it" do
            graph.add_vertex("vertex1")
            graph.add_vertex("vertex2")

            e1 = graph.add_edge("vertex1", "vertex2")
            e2 = graph.add_edge("vertex1", "vertex2")
            e3 = graph.add_edge("vertex1", "vertex2")

            expect(e1).to be_a MOSAIK::Graph::Edge
            expect(e2).to be_a MOSAIK::Graph::Edge
            expect(e3).to be_a MOSAIK::Graph::Edge

            expect(e1).not_to eq e2
            expect(e1).not_to eq e3
            expect(e2).not_to eq e3

            expect(graph.find_edges("vertex1", "vertex2")).to contain_exactly e1, e2, e3
            expect(graph.find_edges("vertex2", "vertex1")).to be_empty
          end
        end
      end

      context "when the graph is undirected" do
        subject(:graph) { build(:graph, directed: false) }

        it "adds an undirected edge and returns it" do
          graph.add_vertex("vertex1")
          graph.add_vertex("vertex2")
          edge = graph.add_edge("vertex1", "vertex2")

          expect(edge).to be_a MOSAIK::Graph::Edge

          expect(graph.find_edges("vertex1", "vertex2")).to contain_exactly edge
          expect(graph.find_edges("vertex2", "vertex1")).to contain_exactly edge
        end

        it "sets the attributes" do
          graph.add_vertex("vertex1")
          graph.add_vertex("vertex2")
          edge = graph.add_edge("vertex1", "vertex2", key: "value")

          expect(edge.attributes).to eq key: "value"
        end

        context "when the edge already exists" do
          it "adds another undirected edge and returns it" do
            graph.add_vertex("vertex1")
            graph.add_vertex("vertex2")

            e1 = graph.add_edge("vertex1", "vertex2")
            e2 = graph.add_edge("vertex1", "vertex2")
            e3 = graph.add_edge("vertex1", "vertex2")

            expect(e1).to be_a MOSAIK::Graph::Edge
            expect(e2).to be_a MOSAIK::Graph::Edge
            expect(e3).to be_a MOSAIK::Graph::Edge

            expect(e1).not_to eq e2
            expect(e1).not_to eq e3
            expect(e2).not_to eq e3

            expect(graph.find_edges("vertex1", "vertex2")).to contain_exactly e1, e2, e3
            expect(graph.find_edges("vertex2", "vertex1")).to contain_exactly e1, e2, e3
          end
        end
      end
    end

    describe "#find_edges" do
      it "returns nothing when no edges exist" do
        graph.add_vertex("vertex1")
        graph.add_vertex("vertex2")

        expect(graph.find_edges("vertex1", "vertex2")).to be_empty
      end

      it "returns all edges" do
        graph.add_vertex("vertex1")
        graph.add_vertex("vertex2")

        e1 = graph.add_edge("vertex1", "vertex2")
        e2 = graph.add_edge("vertex1", "vertex2")

        expect(graph.find_edges("vertex1", "vertex2")).to contain_exactly e1, e2
      end
    end

    describe "#find_edge" do
      it "returns nothing when the edge does not exist" do
        graph.add_vertex("vertex1")
        graph.add_vertex("vertex2")

        expect(graph.find_edge("vertex1", "vertex2")).to be_nil
      end

      it "returns the first edge" do
        graph.add_vertex("vertex1")
        graph.add_vertex("vertex2")

        e1 = graph.add_edge("vertex1", "vertex2")
        graph.add_edge("vertex1", "vertex2")

        expect(graph.find_edge("vertex1", "vertex2")).to eq e1
      end

      context "when attributes are given" do
        it "returns the edge matching the attributes entirely" do
          graph.add_vertex("vertex1")
          graph.add_vertex("vertex2")

          graph.add_edge("vertex1", "vertex2")
          e1 = graph.add_edge("vertex1", "vertex2", weight: 3)

          expect(graph.find_edge("vertex1", "vertex2", weight: 3)).to eq e1
        end

        it "returns the edge matching the attributes partially" do
          graph.add_vertex("vertex1")
          graph.add_vertex("vertex2")

          graph.add_edge("vertex1", "vertex2")
          e1 = graph.add_edge("vertex1", "vertex2", weight: 3, key: "value")

          expect(graph.find_edge("vertex1", "vertex2", weight: 3)).to eq e1
        end

        it "returns nothing when the edge does not have the attributes" do
          graph.add_vertex("vertex1")
          graph.add_vertex("vertex2")

          graph.add_edge("vertex1", "vertex2")
          graph.add_edge("vertex1", "vertex2", weight: 3)

          expect(graph.find_edge("vertex1", "vertex2", weight: 4)).to be_nil
        end
      end
    end

    describe "#find_or_add_edge" do
      it "returns a new edge when the edge does not exist" do
        graph.add_vertex("vertex1")
        graph.add_vertex("vertex2")

        expect(graph.find_or_add_edge("vertex1", "vertex2")).to be_a MOSAIK::Graph::Edge
      end

      it "returns the first edge" do
        graph.add_vertex("vertex1")
        graph.add_vertex("vertex2")

        e1 = graph.add_edge("vertex1", "vertex2")
        graph.add_edge("vertex1", "vertex2")

        expect(graph.find_or_add_edge("vertex1", "vertex2")).to eq e1
      end

      context "when attributes are given" do
        it "adds an edge with attributes" do
          graph.add_vertex("vertex1")
          graph.add_vertex("vertex2")

          expect(graph.find_or_add_edge("vertex1", "vertex2", weight: 3).attributes).to eq weight: 3
        end

        it "returns the edge matching the attributes entirely" do
          graph.add_vertex("vertex1")
          graph.add_vertex("vertex2")

          graph.add_edge("vertex1", "vertex2")
          e1 = graph.add_edge("vertex1", "vertex2", weight: 3)

          expect(graph.find_or_add_edge("vertex1", "vertex2", weight: 3)).to eq e1
        end

        it "returns the edge matching the attributes partially" do
          graph.add_vertex("vertex1")
          graph.add_vertex("vertex2")

          graph.add_edge("vertex1", "vertex2")
          e1 = graph.add_edge("vertex1", "vertex2", weight: 3, key: "value")

          expect(graph.find_or_add_edge("vertex1", "vertex2", weight: 3)).to eq e1
        end

        it "returns a new edge when the edge does not have the attributes" do
          graph.add_vertex("vertex1")
          graph.add_vertex("vertex2")

          graph.add_edge("vertex1", "vertex2")
          graph.add_edge("vertex1", "vertex2", weight: 3)

          expect(graph.find_or_add_edge("vertex1", "vertex2", weight: 4).attributes).to eq weight: 4
        end
      end
    end

    describe "#remove_edge" do
      context "when the graph is directed" do
        subject(:graph) { build(:graph, directed: true) }

        context "when no edge is given" do
          it "removes all edges" do
            graph.add_vertex("vertex1")
            graph.add_vertex("vertex2")
            graph.add_edge("vertex1", "vertex2")
            graph.add_edge("vertex1", "vertex2")

            graph.remove_edge("vertex1", "vertex2")

            expect(graph.find_edges("vertex1", "vertex2")).to be_empty
          end
        end

        context "when a specific edge is given" do
          it "removes the edge" do
            graph.add_vertex("vertex1")
            graph.add_vertex("vertex2")
            e1 = graph.add_edge("vertex1", "vertex2")
            e2 = graph.add_edge("vertex1", "vertex2")

            graph.remove_edge("vertex1", "vertex2", e1)

            expect(graph.find_edges("vertex1", "vertex2")).to contain_exactly e2
          end
        end
      end

      context "when the graph is undirected" do
        subject(:graph) { build(:graph, directed: false) }

        context "when no edge is given" do
          it "removes all edges" do
            graph.add_vertex("vertex1")
            graph.add_vertex("vertex2")
            graph.add_edge("vertex1", "vertex2")
            graph.add_edge("vertex1", "vertex2")

            graph.remove_edge("vertex1", "vertex2")

            expect(graph.find_edges("vertex1", "vertex2")).to be_empty
            expect(graph.find_edges("vertex2", "vertex1")).to be_empty
          end
        end

        context "when a specific edge is given" do
          it "removes the edge" do
            graph.add_vertex("vertex1")
            graph.add_vertex("vertex2")
            e1 = graph.add_edge("vertex1", "vertex2")
            e2 = graph.add_edge("vertex1", "vertex2")

            graph.remove_edge("vertex1", "vertex2", e1)

            expect(graph.find_edges("vertex1", "vertex2")).to contain_exactly e2
            expect(graph.find_edges("vertex2", "vertex1")).to contain_exactly e2
          end
        end
      end
    end
  end

  describe "clusters" do
    describe "#add_cluster" do
      it "adds a cluster" do
        graph.add_cluster("cluster")

        expect(graph.clusters).not_to be_empty
      end

      it "sets the attributes" do
        graph.add_cluster("cluster", key: "value")

        expect(graph.find_cluster("cluster").attributes).to eq key: "value"
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

      it "sets the attributes" do
        graph.find_or_add_cluster("cluster", key: "value")

        expect(graph.find_cluster("cluster").attributes).to eq key: "value"
      end
    end

    describe "#remove_cluster" do
      it "removes a cluster" do
        graph.add_cluster("cluster")
        graph.remove_cluster("cluster")

        expect(graph.clusters).to be_empty
      end

      it "does not remove a non-existing cluster" do
        graph.add_cluster("cluster1")

        graph.remove_cluster("cluster2")

        expect(graph.find_cluster("cluster1")).not_to be_nil
      end
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

    context "when the graph is undirected" do
      subject(:graph) { build(:graph, directed: false) }

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
  end

  describe "#to_csv" do
    context "when the graph is directed" do
      subject(:graph) { build(:graph, directed: true, attrs: { name: "My graph" }) }

      it "returns a CSV" do
        graph.add_vertex("vertex1", type: "class")
        graph.add_vertex("vertex2", type: "interface")
        graph.add_vertex("vertex3", type: "module")
        graph.add_edge("vertex1", "vertex2")
        graph.add_edge("vertex2", "vertex3", method: "method", weight: 1.0)

        expect(graph.to_csv).to eq <<~CSV
          directed,version,name
          true,1,My graph
          --
          id,type
          vertex1,class
          vertex2,interface
          vertex3,module
          --
          from,to,method,weight
          vertex1,vertex2,,
          vertex2,vertex3,method,1.0
        CSV
      end
    end

    context "when the graph is undirected" do
      subject(:graph) { build(:graph, directed: false, attrs: { name: "My graph" }) }

      it "returns a CSV" do
        graph.add_vertex("vertex1", type: "class")
        graph.add_vertex("vertex2", type: "interface")
        graph.add_vertex("vertex3", type: "module")
        graph.add_edge("vertex1", "vertex2")
        graph.add_edge("vertex2", "vertex3", method: "method", weight: 1.0)

        expect(graph.to_csv).to eq <<~CSV
          directed,version,name
          false,1,My graph
          --
          id,type
          vertex1,class
          vertex2,interface
          vertex3,module
          --
          from,to,method,weight
          vertex1,vertex2,,
          vertex2,vertex3,method,1.0
        CSV
      end
    end

    context "when the graph has clusters" do
      it "returns a CSV" do
        v1 = graph.add_vertex("vertex1", type: "class")
        v2 = graph.add_vertex("vertex2", type: "interface")
        v3 = graph.add_vertex("vertex3", type: "module")
        graph.add_edge("vertex1", "vertex2")
        graph.add_edge("vertex2", "vertex3", method: "method", weight: 1.0)

        c1 = graph.add_cluster("cluster1", type: "database")
        c1.add_vertex(v1)
        c1.add_vertex(v2)

        c2 = graph.add_cluster("cluster2", type: "microservice")
        c2.add_vertex(v3)

        graph.add_cluster("cluster3")

        expect(graph.to_csv).to eq <<~CSV
          directed,version,key
          true,1,value
          --
          id,type
          vertex1,class
          vertex2,interface
          vertex3,module
          --
          from,to,method,weight
          vertex1,vertex2,,
          vertex2,vertex3,method,1.0
          --
          vertex,cluster,type
          vertex1,cluster1,database
          vertex2,cluster1,database
          vertex3,cluster2,microservice
        CSV
      end
    end
  end

  describe ".from_csv" do
    it "raises an error when the graph version is unsupported" do
      csv = <<~CSV
        directed,version,name
        true,0,My graph
      CSV

      expect { described_class.from_csv(csv) }.to raise_error MOSAIK::Error, "Unsupported graph version: 0"
    end

    context "when the graph is directed" do
      it "creates a graph from a CSV" do
        csv = <<~CSV
          directed,version,name
          true,1,My graph
          --
          id,type
          vertex1,class
          vertex2,interface
          vertex3,module
          --
          from,to,method,weight
          vertex1,vertex2,
          vertex2,vertex3,method,1.0
        CSV

        graph = described_class.from_csv(csv)

        expect(graph.directed).to be true
        expect(graph.attributes[:name]).to eq "My graph"

        expect(graph.vertices.keys).to eq ["vertex1", "vertex2", "vertex3"]
        expect(graph.find_vertex("vertex1").attributes).to eq type: "class"
        expect(graph.find_vertex("vertex2").attributes).to eq type: "interface"
        expect(graph.find_vertex("vertex3").attributes).to eq type: "module"

        expect(graph.find_vertex("vertex1").edges.keys).to eq ["vertex2"]

        expect(graph.find_edge("vertex2", "vertex3").attributes).to eq method: "method", weight: 1.0

        expect(graph.find_vertex("vertex3").edges).to be_empty
      end
    end

    context "when the graph is undirected" do
      it "creates a graph from a CSV" do
        csv = <<~CSV
          directed,version,name
          false,1,My graph
          --
          id,type
          vertex1,class
          vertex2,interface
          vertex3,module
          --
          from,to,method,weight
          vertex1,vertex2,,
          vertex2,vertex3,method,1.0
        CSV

        graph = described_class.from_csv(csv)

        expect(graph.directed).to be false
        expect(graph.attributes[:name]).to eq "My graph"

        expect(graph.vertices.keys).to eq ["vertex1", "vertex2", "vertex3"]
        expect(graph.find_vertex("vertex1").attributes).to eq type: "class"
        expect(graph.find_vertex("vertex2").attributes).to eq type: "interface"
        expect(graph.find_vertex("vertex3").attributes).to eq type: "module"

        expect(graph.find_vertex("vertex1").edges.keys).to eq ["vertex2"]
        expect(graph.find_vertex("vertex2").edges.keys).to eq ["vertex1", "vertex3"]
        expect(graph.find_edge("vertex2", "vertex3").attributes).to eq method: "method", weight: 1.0

        expect(graph.find_vertex("vertex3").edges.keys).to eq ["vertex2"]
        expect(graph.find_edge("vertex3", "vertex2").attributes).to eq method: "method", weight: 1.0

        expect(graph.find_edge("vertex2", "vertex3")).to eq graph.find_edge("vertex3", "vertex2")
      end
    end

    context "when the graph has clusters" do
      it "creates a graph from a CSV" do
        csv = <<~CSV
          directed,version,name
          true,1,My graph
          --
          id,type
          vertex1,class
          vertex2,interface
          vertex3,module
          --
          from,to,method,weight
          vertex1,vertex2,,
          vertex2,vertex3,method,1.0
          --
          vertex,cluster,type
          vertex1,cluster1,database
          vertex2,cluster1,database
          vertex3,cluster2,microservice
        CSV

        graph = described_class.from_csv(csv)

        expect(graph.directed).to be true
        expect(graph.attributes[:name]).to eq "My graph"

        expect(graph.vertices.keys).to eq ["vertex1", "vertex2", "vertex3"]
        expect(graph.find_vertex("vertex1").attributes).to eq type: "class"
        expect(graph.find_vertex("vertex2").attributes).to eq type: "interface"
        expect(graph.find_vertex("vertex3").attributes).to eq type: "module"

        expect(graph.find_vertex("vertex1").edges.keys).to eq ["vertex2"]

        expect(graph.find_edge("vertex2", "vertex3").attributes).to eq method: "method", weight: 1.0

        expect(graph.find_vertex("vertex3").edges).to be_empty

        expect(graph.clusters.keys).to eq ["cluster1", "cluster2"]
        expect(graph.find_cluster("cluster1").vertices.map(&:id)).to eq ["vertex1", "vertex2"]
        expect(graph.find_cluster("cluster1").attributes).to eq type: "database"

        expect(graph.find_cluster("cluster2").vertices.map(&:id)).to eq ["vertex3"]
        expect(graph.find_cluster("cluster2").attributes).to eq type: "microservice"
      end
    end
  end
end
