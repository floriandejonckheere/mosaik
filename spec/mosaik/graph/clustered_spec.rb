# frozen_string_literal: true

RSpec.describe MOSAIK::Graph::Clustered do
  subject(:graph) { described_class.new }

  describe "#to_dot" do
    it "returns the graph in DOT format" do
      graph.add_cluster("1")
      graph.add_component("1", "A")
      graph.add_component("1", "B")

      graph.add_cluster("2")
      graph.add_component("2", "C")
      graph.add_component("2", "D")
      graph.add_component("2", "E")

      expect(graph.to_dot).to eq <<~DOT
        graph {
          subgraph "cluster_1" {
            label = "Cluster 1"
            color = "lightblue"

            node [shape=circle, style=filled, fillcolor=lightblue]

            "A" -- "1"
            "B" -- "1"
          }

          subgraph "cluster_2" {
            label = "Cluster 2"
            color = "lightblue"

            node [shape=circle, style=filled, fillcolor=lightblue]

            "C" -- "2"
            "D" -- "2"
            "E" -- "2"
          }

        }
      DOT
    end
  end

  describe "#to_csv" do
    it "returns a cluster membership list" do
      graph.add_cluster("1")
      graph.add_component("1", "A")
      graph.add_component("1", "B")

      graph.add_cluster("2")
      graph.add_component("2", "C")
      graph.add_component("2", "D")
      graph.add_component("2", "E")

      expect(graph.to_csv).to eq <<~CSV
        cluster,component
        1,A
        1,B
        2,C
        2,D
        2,E
      CSV
    end
  end
end
