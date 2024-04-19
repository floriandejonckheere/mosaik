# frozen_string_literal: true

RSpec.describe MOSAIK::Metrics::ABCSize do
  subject(:metric) { build(:abc_size_metric, options:, graph:) }

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

  # ABC size value calculated by hand:
  #
  # Cluster 1: 1.0
  # Cluster 2: 15.04 + 5.0
  #
  # ABC size = 21.04
  #

  it "sets the ABC size values for each vertex, cluster, and for the graph" do
    metric.evaluate

    expect(graph.find_vertex("CoreExt::Object").attributes[:abc_size]).to eq 1.0
    expect(graph.find_vertex("MOSAIK::Logger").attributes[:abc_size]).to eq 15.04
    expect(graph.find_vertex("MOSAIK::Algorithm").attributes[:abc_size]).to eq 5.0

    expect(graph.find_cluster("cluster1").attributes[:abc_size]).to eq 1.0
    expect(graph.find_cluster("cluster2").attributes[:abc_size]).to eq 20.04

    expect(graph.attributes[:abc_size]).to eq 21.04
  end
end
