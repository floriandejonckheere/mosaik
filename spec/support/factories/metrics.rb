# frozen_string_literal: true

FactoryBot.define do
  factory :metric, class: "MOSAIK::Metric" do
    initialize_with { new(options, graph) }

    options { {} }
    graph
  end

  factory :modularity_metric, parent: :metric, class: "MOSAIK::Metrics::Modularity"
end
