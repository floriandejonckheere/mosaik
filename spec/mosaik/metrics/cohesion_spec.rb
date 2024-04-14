# frozen_string_literal: true

RSpec.describe MOSAIK::Metrics::Cohesion do
  subject(:metric) { build(:cohesion_metric, graph:) }

  # Cohesion value calculated by hand:
  #
  # Directed:
  #   Cluster A: |A| = 11: (2 + 1 + 0) / (11 * 10 / 2) = 0.05454545454545454
  #   Cluster B: |B| = 8:  (1 + 0) / (8 * 7 / 2) = 0.03571428571428571
  #   Cluster C: |C| = 1: 0
  #
  #   Cohesion = 0.05454545454545454 + 0.03571428571428571 + 0 = 0.09025974025974026
  #
  # Undirected:
  #   Cluster A: |A| = 11: (2 + 1 + 0) / (11 * 10 / 2) = 0.05454545454545454
  #   Cluster B: |B| = 8:  (1 + 0) / (8 * 7 / 2) = 0.03571428571428571
  #   Cluster C: |C| = 1: 0
  #
  #   Cohesion = 0.05454545454545454 + 0.03571428571428571 + 0 = 0.09025974025974026
  #

  context "when the graph is directed" do
    include_context "with a simple directed graph"

    it "sets the cohesion values for each cluster, and for the graph" do
      metric.evaluate

      expect(graph.find_cluster("A").attributes[:cohesion]).to eq 0.05454545454545454
      expect(graph.find_cluster("B").attributes[:cohesion]).to eq 0.03571428571428571
      expect(graph.find_cluster("C").attributes[:cohesion]).to eq 0.0
      expect(graph.attributes[:cohesion]).to eq 0.09025974025974026
    end

    it "returns the total cohesion" do
      expect(metric.evaluate).to eq 0.09025974025974026
    end
  end

  context "when the graph is undirected" do
    include_context "with a simple undirected graph"

    it "sets the cohesion values for each cluster, and for the graph" do
      metric.evaluate

      expect(graph.find_cluster("A").attributes[:cohesion]).to eq 0.05454545454545454
      expect(graph.find_cluster("B").attributes[:cohesion]).to eq 0.03571428571428571
      expect(graph.find_cluster("C").attributes[:cohesion]).to eq 0.0
      expect(graph.attributes[:cohesion]).to eq 0.09025974025974026
    end

    it "returns the total cohesion" do
      expect(metric.evaluate).to eq 0.09025974025974026
    end
  end
end
