# frozen_string_literal: true

RSpec.describe MOSAIK::Graph::Visualizer do
  subject(:visualizer) { described_class.new(options, graph) }

  let(:options) { {} }
  let(:graph) { build(:graph) }

  describe "#to_dot" do
    context "when the graph is directed" do
      let(:graph) { build(:graph, directed: true) }

      it "returns the graph in DOT format" do
        graph.add_vertex("vertex1")
        graph.add_vertex("vertex2")
        graph.add_vertex("vertex3")
        graph.add_edge("vertex1", "vertex2")
        graph.add_edge("vertex2", "vertex3", foo: "bar", baz: "bat")

        expect(visualizer.to_dot).to eq <<~DOT
          digraph {
            "vertex1" [shape=circle, width=1, fixedsize=true, fontsize=12, style=filled, fillcolor=lightblue]
            "vertex1" -> "vertex2"
            "vertex2" [shape=circle, width=1, fixedsize=true, fontsize=12, style=filled, fillcolor=lightblue]
            "vertex2" -> "vertex3" [label="foo: bar, baz: bat"]
            "vertex3" [shape=circle, width=1, fixedsize=true, fontsize=12, style=filled, fillcolor=lightblue]
          }
        DOT
      end
    end

    context "when the graph is undirected" do
      let(:graph) { build(:graph, directed: false) }

      it "returns the graph in DOT format" do
        graph.add_vertex("vertex1")
        graph.add_vertex("vertex2")
        graph.add_vertex("vertex3")
        graph.add_edge("vertex1", "vertex2")
        graph.add_edge("vertex2", "vertex3", foo: "bar", baz: "bat")

        expect(visualizer.to_dot).to eq <<~DOT
          graph {
            "vertex1" [shape=circle, width=1, fixedsize=true, fontsize=12, style=filled, fillcolor=lightblue]
            "vertex1" -- "vertex2"
            "vertex2" [shape=circle, width=1, fixedsize=true, fontsize=12, style=filled, fillcolor=lightblue]
            "vertex2" -- "vertex3" [label="foo: bar, baz: bat"]
            "vertex3" [shape=circle, width=1, fixedsize=true, fontsize=12, style=filled, fillcolor=lightblue]
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

        expect(visualizer.to_dot).to eq <<~DOT
          digraph {
            subgraph "cluster1" {
              cluster = true
              label = "cluster1"
              color = "gray"
              "vertex1"
              "vertex2"
              "vertex3"
            }
            subgraph "cluster2" {
              cluster = true
              label = "cluster2"
              color = "gray"
              "vertex4"
            }
            subgraph "cluster3" {
              cluster = true
              label = "cluster3"
              color = "gray"
            }
            "vertex1" [shape=circle, width=1, fixedsize=true, fontsize=12, style=filled, fillcolor=lightblue]
            "vertex1" -> "vertex2"
            "vertex1" -> "vertex3"
            "vertex1" -> "vertex4"
            "vertex2" [shape=circle, width=1, fixedsize=true, fontsize=12, style=filled, fillcolor=lightblue]
            "vertex2" -> "vertex3" [label="foo: bar, baz: bat"]
            "vertex3" [shape=circle, width=1, fixedsize=true, fontsize=12, style=filled, fillcolor=lightblue]
            "vertex4" [shape=circle, width=1, fixedsize=true, fontsize=12, style=filled, fillcolor=lightblue]
            "vertex5" [shape=circle, width=1, fixedsize=true, fontsize=12, style=filled, fillcolor=lightblue]
            "vertex5" -> "vertex5"
          }
        DOT
      end
    end

    context "when uncoupled vertices are hidden" do
      let(:options) { { hide_uncoupled: true } }

      it "returns the graph in DOT format" do
        graph.add_vertex("vertex1")
        graph.add_vertex("vertex2")
        graph.add_vertex("vertex3")
        graph.add_edge("vertex1", "vertex2", foo: "bar", baz: "bat")

        expect(visualizer.to_dot).to eq <<~DOT
          digraph {
            "vertex1" [shape=circle, width=1, fixedsize=true, fontsize=12, style=filled, fillcolor=lightblue]
            "vertex1" -> "vertex2" [label="foo: bar, baz: bat"]
            "vertex2" [shape=circle, width=1, fixedsize=true, fontsize=12, style=filled, fillcolor=lightblue]
          }
        DOT
      end
    end

    context "when labels are hidden" do
      let(:options) { { hide_labels: true } }

      it "returns the graph in DOT format" do
        graph.add_vertex("vertex1")
        graph.add_vertex("vertex2")
        graph.add_edge("vertex1", "vertex2", weight: 3)

        expect(visualizer.to_dot).to eq <<~DOT
          digraph {
            "vertex1" [shape=circle, width=1, fixedsize=true, fontsize=12, style=filled, fillcolor=lightblue]
            "vertex1" -> "vertex2"
            "vertex2" [shape=circle, width=1, fixedsize=true, fontsize=12, style=filled, fillcolor=lightblue]
          }
        DOT
      end
    end
  end
end
