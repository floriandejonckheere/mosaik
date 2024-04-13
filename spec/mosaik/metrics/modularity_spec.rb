# frozen_string_literal: true

RSpec.describe MOSAIK::Metrics::Modularity do
  subject(:metric) { build(:modularity_metric, graph:) }

  let(:graph) do
    graph = build(:graph)

    a = graph.add_vertex("A")
    b = graph.add_vertex("B")
    c = graph.add_vertex("C")
    d = graph.add_vertex("D")
    e = graph.add_vertex("E")
    f = graph.add_vertex("F")

    graph.add_edge("A", "B", weight: 3.0)
    graph.add_edge("A", "C", weight: 1.0)
    graph.add_edge("A", "D", weight: 5.0)

    graph.add_edge("B", "C", weight: 1.0)
    graph.add_edge("B", "D", weight: 4.0)

    graph.add_edge("C", "D", weight: 1.0)
    graph.add_edge("C", "E", weight: 5.0)

    graph.add_edge("D", "F", weight: 2.0)

    c1 = graph.add_cluster("A")
    c1.add_vertex(a)
    c1.add_vertex(b)
    c1.add_vertex(d)

    c2 = graph.add_cluster("B")
    c2.add_vertex(c)
    c2.add_vertex(e)

    c3 = graph.add_cluster("C")
    c3.add_vertex(f)

    graph
  end

  it "returns the modularity of the graph" do
    expect(metric.evaluate).to be_within(1e-6).of 0.621900826446281
  end
end
