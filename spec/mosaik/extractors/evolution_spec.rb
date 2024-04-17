# frozen_string_literal: true

RSpec.describe MOSAIK::Extractors::Evolution do
  subject(:extractor) { described_class.new(options, graph) }

  let(:options) { { directory: MOSAIK.root, limit: 100 } }
  let(:graph) { build(:graph) }

  describe "#validate" do
    it "does not raise an error" do
      expect { extractor.validate }.not_to raise_error
    end

    context "when the directory is not a git repository root" do
      let(:options) { { directory: "/tmp" } }

      it "raises an error" do
        expect { extractor.validate }.to raise_error MOSAIK::OptionError, "directory is not a git repository"
      end
    end
  end

  describe "#call" do
    let(:options) { { directory: "tmp/repository", limit: 100, logical: 1, contributor: 0 } }

    it "constructs a logical coupling graph" do
      extractor.call

      # Extract all vertices with source and destination
      expect(graph.vertices.transform_values { |v| v.edges.transform_values { |es| es.select { |e| e.attributes[:type] == "logical" }.sum { |e| e.attributes[:weight] } } }).to eq(
        "App::Foo" => { "App::Bak" => 1, "App::Bat" => 1, "App::Bar" => 1, "App::Baz" => 0 },
        "App::Bar" => { "App::Foo" => 1 },
        "App::Bat" => { "App::Baz" => 3, "App::Foo" => 1 },
        "App::Bak" => { "App::Foo" => 1 },
        "App::Baz" => { "App::Bat" => 3, "App::Foo" => 0 },
      )
    end

    it "constructs a contributor coupling graph" do
      extractor.call

      # Extract all vertices with source and destination
      expect(graph.vertices.transform_values { |v| v.edges.transform_values { |es| es.select { |e| e.attributes[:type] == "contributor" }.sum { |e| e.attributes[:weight] } } }).to eq(
        "App::Bak" => { "App::Foo" => 0 },
        "App::Bar" => { "App::Foo" => 0 },
        "App::Foo" => { "App::Baz" => 2, "App::Bat" => 2, "App::Bak" => 0, "App::Bar" => 0 },
        "App::Bat" => { "App::Baz" => 3, "App::Foo" => 2 },
        "App::Baz" => { "App::Bat" => 3, "App::Foo" => 2 },
      )
    end
  end
end
