# frozen_string_literal: true

RSpec.describe MOSAIK::Graph::Statistics do
  subject(:statistics) { described_class.new(options, graph) }

  let(:options) { { metrics: [:abc_size, :cohesion, :complexity, :coupling, :modularity] } }
  let(:graph) { build(:graph) }

  before do
    graph.add_cluster("cluster1", abc_size: 1.0, cohesion: 0.5, complexity: 0.3, coupling: 0.2, modularity: 0.1)
    graph.add_cluster("cluster2", abc_size: 2.0, cohesion: 0.4, complexity: 0.2, coupling: 0.3, modularity: 0.2)
    graph.add_cluster("cluster3", abc_size: 1.5, cohesion: 0.3, complexity: 0.2, coupling: 0.3, modularity: 0.1)
  end

  describe "#call" do
    it "computes the statistics" do
      expect(statistics.call.transform_values { |s| s.transform_values { |f| f.round(2) } })
        .to eq "abc_size" => { "min" => 1.0, "max" => 2.0, "mean" => 1.5, "q1" => 1.0, "q2" => 1.5, "q3" => 2.0 },
               "cohesion" => { "min" => 0.3, "max" => 0.5, "mean" => 0.4, "q1" => 0.3, "q2" => 0.4, "q3" => 0.5 },
               "complexity" => { "min" => 0.2, "max" => 0.3, "mean" => 0.23, "q1" => 0.2, "q2" => 0.2, "q3" => 0.3 },
               "coupling" => { "min" => 0.2, "max" => 0.3, "mean" => 0.27, "q1" => 0.2, "q2" => 0.3, "q3" => 0.3 },
               "modularity" => { "min" => 0.1, "max" => 0.2, "mean" => 0.13, "q1" => 0.1, "q2" => 0.1, "q3" => 0.2 }
    end
  end
end
