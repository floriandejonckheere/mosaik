# frozen_string_literal: true

RSpec.describe MOSAIK::Extractors::Structural do
  subject(:extractor) { described_class.new(options, graph) }

  let(:options) { {} }
  let(:graph) { build(:graph) }

  describe "#validate" do
    it "does not raise an error" do
      expect { extractor.validate }.not_to raise_error
    end
  end

  describe "#call" do
    it "constructs a logical coupling graph" do
      extractor.call

      # Extract constants and methods
      expect(graph.vertices.transform_values { |v| v.attributes[:methods] }).to eq(
        "App" => 0,
        "App::Foo" => 2,
        "App::Bar" => 0,
        "App::Bat" => 1,
        "App::Bak" => 0,
        "App::Baz" => 0,
      )

      # Extract all vertices with source and destination
      expect(graph.vertices.transform_values { |v| v.edges.transform_values { |es| es.select { |e| e.attributes[:type] == "structural" }.map { |e| e.attributes[:weight] } } }).to eq(
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
