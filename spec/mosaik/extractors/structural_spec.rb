# frozen_string_literal: true

RSpec.describe MOSAIK::Extractors::Structural do
  subject(:extractor) { described_class.new(options, graph) }

  let(:options) { { structural: 1 } }
  let(:graph) { build(:graph) }

  describe "#validate" do
    it "does not raise an error" do
      expect { extractor.validate }.not_to raise_error
    end
  end

  context "when the weight is zero" do
    let(:options) { { structural: 0 } }

    it "does not extract structural coupling information" do
      expect { extractor.call }.not_to(change { graph.vertices.count })
    end
  end

  describe "structural coupling" do
    let(:options) { { structural: 1 } }

    include_context "with a git repository"

    it "constructs a logical coupling graph" do
      extractor.call

      # Extract all vertices with source and destination
      expect(graph.vertices.transform_values { |v| v.edges.transform_values { |es| es.map { |e| e.attributes[:weight] } } }).to eq(
        "App" => {},
        "App::Foo" => {},
        "App::Bar" => {},
        "App::Bat" => {},
        "App::Bak" => {},
        "App::Baz" => {},
      )
    end
  end
end
