# frozen_string_literal: true

RSpec.shared_context "with a simple directed graph" do
  let(:graph) do
    graph = build(:graph, directed: true)

    a = graph.add_vertex("A", methods: 3)
    b = graph.add_vertex("B", methods: 2)
    c = graph.add_vertex("C", methods: 3)
    d = graph.add_vertex("D", methods: 6)
    e = graph.add_vertex("E", methods: 5)
    f = graph.add_vertex("F", methods: 1)

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
end
