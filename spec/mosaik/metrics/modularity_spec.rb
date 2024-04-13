# frozen_string_literal: true

RSpec.describe MOSAIK::Metrics::Modularity do
  subject(:metric) { build(:modularity_metric, graph:) }

  # Modularity value calculated by hand:
  #
  # m = 3 + 1 + 5 + 1 + 4 + 1 + 5 + 2 = 22 (total weight)
  #
  # Cluster A
  #   c_weight_internal = 3 + 5 + 4 = 12
  #   c_weight_total = 3 + 5 + 4 + 1 + 1 + 1 + 2 = 17
  #
  # Q_a = (12/44) - (17/44)**2 = 0.12345041322314049
  #
  # Cluster B
  #   c_weight_internal = 5
  #   c_weight_total = 5 + 1 + 1 + 1 = 8
  #
  # Q_b = (5/44) - (8/44)**2 = 0.08057851239669421
  #
  # Cluster C
  #   c_weight_internal = 0
  #   c_weight_total = 2
  #
  # Q_c = - (2/44)**2 = -0.002066115702479339
  #
  # Q_tot = 0.20196280991735538
  #
  context "when the graph is undirected" do
    include_context "with a simple undirected graph"

    it "returns the modularity of the graph" do
      expect(metric.evaluate).to be_within(1e-6).of 0.20196280991735538
    end
  end

  context "when the graph is directed" do
    include_context "with a simple directed graph"

    it "returns the modularity of the graph" do
      expect(metric.evaluate).to be_within(1e-6).of 0.20196280991735538
    end
  end
end
