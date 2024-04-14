# frozen_string_literal: true

RSpec.describe MOSAIK::Metrics::Coupling do
  subject(:metric) { build(:coupling_metric, graph:) }

  # Coupling value calculated by hand:
  #
  # Directed:
  #   Cluster A: 1 + 1 + 2
  #   Cluster B: 1
  #   Cluster C: 0
  #
  #   Coupling = 5
  #
  # Undirected:
  #   Cluster A: 1 + 1 + 1 + 2
  #   Cluster B: 1 + 1 + 1
  #   Cluster C: 2
  #
  #   Coupling = 10
  #

  context "when the graph is directed" do
    include_context "with a simple directed graph"

    it "sets the coupling values for each cluster, and for the graph" do
      metric.evaluate

      expect(graph.find_cluster("A").attributes[:coupling]).to eq 4.0
      expect(graph.find_cluster("B").attributes[:coupling]).to eq 1.0
      expect(graph.find_cluster("C").attributes[:coupling]).to eq 0.0
      expect(graph.attributes[:coupling]).to eq 5.0
    end

    it "returns the total coupling" do
      expect(metric.evaluate).to eq 5.0
    end
  end

  context "when the graph is undirected" do
    include_context "with a simple undirected graph"

    it "sets the coupling values for each cluster, and for the graph" do
      metric.evaluate

      expect(graph.find_cluster("A").attributes[:coupling]).to eq 5.0
      expect(graph.find_cluster("B").attributes[:coupling]).to eq 3.0
      expect(graph.find_cluster("C").attributes[:coupling]).to eq 2.0
      expect(graph.attributes[:coupling]).to eq 10.0
    end

    it "returns the total coupling" do
      expect(metric.evaluate).to eq 10.0
    end
  end
end
