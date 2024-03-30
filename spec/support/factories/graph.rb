# frozen_string_literal: true

FactoryBot.define do
  factory :graph, class: "MOSAIK::Graph::Graph"

  factory :vertex, class: "MOSAIK::Graph::Vertex" do
    initialize_with { new(value) }

    value { "vertex" }
  end
end
