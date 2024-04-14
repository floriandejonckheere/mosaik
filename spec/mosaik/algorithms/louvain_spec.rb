# frozen_string_literal: true
# typed: true

RSpec.describe MOSAIK::Algorithms::Louvain do
  subject(:algorithm) { described_class.new(options, graph) }

  let(:options) { {} }

  include_context "with a simple undirected graph"

  describe "#reduce_graph" do
    it "returns a reduced graph" do
      reduced_graph, reduced_mapping = algorithm.send(:reduce_graph, graph)

      expect(reduced_graph.vertices.keys).to eq ["A", "B", "C"]

      expect(reduced_graph.find_vertex("A").edges.transform_values { |es| es.map(&:attributes) }).to eq "B" => [{ weight: 3.0 }], "C" => [{ weight: 2.0 }]
      expect(reduced_graph.find_vertex("B").edges.transform_values { |es| es.map(&:attributes) }).to eq "A" => [{ weight: 3.0 }]
      expect(reduced_graph.find_vertex("C").edges.transform_values { |es| es.map(&:attributes) }).to eq "A" => [{ weight: 2.0 }]

      expect(reduced_mapping).to eq "A" => "A", "B" => "A", "C" => "B", "D" => "A", "E" => "B", "F" => "C"
    end
  end
end
