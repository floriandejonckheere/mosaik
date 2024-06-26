# frozen_string_literal: true

FactoryBot.define do
  factory :graph, class: "MOSAIK::Graph::Graph" do
    initialize_with { new(attrs, directed:) }

    attrs { { key: "value" } }
    directed { true }
  end

  factory :vertex, class: "MOSAIK::Graph::Vertex" do
    initialize_with { new(id, attrs) }

    id { "vertex" }
    attrs { { key: "value" } }
  end

  factory :edge, class: "MOSAIK::Graph::Edge" do
    initialize_with { new(attrs) }

    attrs { { key: "value" } }
  end

  factory :cluster, class: "MOSAIK::Graph::Cluster" do
    initialize_with { new(id, attrs) }

    id { "cluster" }
    attrs { { key: "value" } }
  end
end
