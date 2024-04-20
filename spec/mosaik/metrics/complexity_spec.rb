# frozen_string_literal: true
# typed: true

RSpec.describe MOSAIK::Metrics::Complexity do
  subject(:metric) { build(:complexity_metric, options:, graph:) }

  let(:options) { { directory: MOSAIK.root } }
  let(:graph) { build(:graph) }

  before do
    v1 = graph.add_vertex("CoreExt::Object")
    v2 = graph.add_vertex("MOSAIK::Logger")
    v3 = graph.add_vertex("MOSAIK::Algorithm")

    c1 = graph.add_cluster("cluster1")
    c2 = graph.add_cluster("cluster2")

    c1.add_vertex(v1)

    c2.add_vertex(v2)
    c2.add_vertex(v3)
  end

  # Cyclomatic complexity calculated by hand:
  #
  # Cluster 1: 1.0 / 1 = 1.0
  # Cluster 2: 7.0 / 2 + 1.0 / 3 = 5.83 (rounded)
  #
  # Complexity = 6.83 (rounded)
  #

  it "sets the ABC size values for each vertex, cluster, and for the graph" do
    metric.evaluate

    expect(graph.find_vertex("CoreExt::Object").attributes[:complexity]).to be_within(1e-2).of 1.0
    expect(graph.find_vertex("MOSAIK::Logger").attributes[:complexity]).to be_within(1e-2).of 5.5
    expect(graph.find_vertex("MOSAIK::Algorithm").attributes[:complexity]).to be_within(1e-2).of 0.33

    expect(graph.find_cluster("cluster1").attributes[:complexity]).to be_within(1e-2).of 1.0
    expect(graph.find_cluster("cluster2").attributes[:complexity]).to be_within(1e-2).of 5.83

    expect(graph.attributes[:complexity]).to be_within(1e-2).of 6.83
  end
end
