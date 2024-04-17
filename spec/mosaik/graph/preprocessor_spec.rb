# frozen_string_literal: true
# typed: true

RSpec.describe MOSAIK::Graph::Preprocessor do
  subject(:preprocessor) { described_class.new(options, graph) }

  let(:options) { { structural: 0.5, logical: 0.3, contributor: 0.2 } }
  let(:graph) { build(:graph) }

  before do
    graph.add_vertex("v1")
    graph.add_vertex("v2")
    graph.add_vertex("v3")

    graph.add_edge("v1", "v2", type: "structural", weight: 2, method: "read")
    graph.add_edge("v1", "v2", type: "structural", weight: 3, method: "write")
    graph.add_edge("v2", "v3", type: "structural", weight: 3, method: "read")
    graph.add_edge("v3", "v2", type: "structural", weight: 1, method: "write")

    graph.add_edge("v1", "v2", type: "logical", weight: 2)
    graph.add_edge("v1", "v2", type: "logical", weight: 3)
    graph.add_edge("v2", "v3", type: "logical", weight: 3)
    graph.add_edge("v3", "v2", type: "logical", weight: 1)

    graph.add_edge("v1", "v2", type: "contributor", weight: 2)
    graph.add_edge("v1", "v2", type: "contributor", weight: 3)
    graph.add_edge("v2", "v3", type: "contributor", weight: 3)
    graph.add_edge("v3", "v2", type: "contributor", weight: 1)
  end

  it "changes the graph to undirected" do
    expect(graph).to be_directed

    preprocessor.call

    expect(graph).not_to be_directed
  end

  it "aggregates the weights of the edges between vertices" do
    preprocessor.call

    v1_v2 = ((0.5 * 2) + (0.5 * 3)) + ((0.3 * 2) + (0.3 * 3)) + ((0.2 * 2) + (0.2 * 3))
    v2_v3 = ((0.5 * 3) + (0.5 * 1)) + ((0.3 * 3) + (0.3 * 1)) + ((0.2 * 3) + (0.2 * 1))

    expect(graph.find_edge("v1", "v2").attributes[:weight]).to eq v1_v2
    expect(graph.find_edge("v2", "v1").attributes[:weight]).to eq v1_v2

    expect(graph.find_edge("v2", "v3").attributes[:weight]).to eq v2_v3
    expect(graph.find_edge("v3", "v2").attributes[:weight]).to eq v2_v3
  end

  describe "structural coupling" do
    let(:options) { { structural: 0.5, logical: 0.0, contributor: 0.0 } }

    it "aggregates the weights of the edges between vertices" do
      preprocessor.call

      v1_v2 = (0.5 * 2) + (0.5 * 3)
      v2_v3 = (0.5 * 3) + (0.5 * 1)

      expect(graph.find_edge("v1", "v2").attributes[:weight]).to eq v1_v2
      expect(graph.find_edge("v2", "v1").attributes[:weight]).to eq v1_v2

      expect(graph.find_edge("v2", "v3").attributes[:weight]).to eq v2_v3
      expect(graph.find_edge("v3", "v2").attributes[:weight]).to eq v2_v3
    end
  end

  describe "logical coupling" do
    let(:options) { { structural: 0.0, logical: 0.3, contributor: 0.0 } }

    it "aggregates the weights of the edges between vertices" do
      preprocessor.call

      v1_v2 = (0.3 * 2) + (0.3 * 3)
      v2_v3 = (0.3 * 3) + (0.3 * 1)

      expect(graph.find_edge("v1", "v2").attributes[:weight]).to eq v1_v2
      expect(graph.find_edge("v2", "v1").attributes[:weight]).to eq v1_v2

      expect(graph.find_edge("v2", "v3").attributes[:weight]).to eq v2_v3
      expect(graph.find_edge("v3", "v2").attributes[:weight]).to eq v2_v3
    end
  end

  describe "contributor coupling" do
    let(:options) { { structural: 0.0, logical: 0.0, contributor: 0.1 } }

    it "aggregates the weights of the edges between vertices" do
      preprocessor.call

      v1_v2 = (0.1 * 2) + (0.1 * 3)
      v2_v3 = (0.1 * 3) + (0.1 * 1)

      expect(graph.find_edge("v1", "v2").attributes[:weight]).to eq v1_v2
      expect(graph.find_edge("v2", "v1").attributes[:weight]).to eq v1_v2

      expect(graph.find_edge("v2", "v3").attributes[:weight]).to eq v2_v3
      expect(graph.find_edge("v3", "v2").attributes[:weight]).to eq v2_v3
    end
  end
end
