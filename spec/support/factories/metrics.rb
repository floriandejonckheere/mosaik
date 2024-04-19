# frozen_string_literal: true

FactoryBot.define do
  factory :metric, class: "MOSAIK::Metric" do
    initialize_with { new(options, graph) }

    options { {} }
    graph
  end

  factory :abc_size_metric, parent: :metric, class: "MOSAIK::Metrics::ABCSize"

  factory :cohesion_metric, parent: :metric, class: "MOSAIK::Metrics::Cohesion"

  factory :complexity_metric, parent: :metric, class: "MOSAIK::Metrics::Complexity"

  factory :coupling_metric, parent: :metric, class: "MOSAIK::Metrics::Coupling"

  factory :modularity_metric, parent: :metric, class: "MOSAIK::Metrics::Modularity"
end
