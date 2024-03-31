# frozen_string_literal: true

RSpec.describe MOSAIK::Extractors::Evolution do
  subject(:extractor) { described_class.new(options, graph) }

  let(:options) { { directory: MOSAIK.root, limit: 100, logical: 1, contributor: 1 } }
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

  context "when the weights are zero" do
    let(:options) { { logical: 0, contributor: 0 } }

    it "does not extract evolutionary coupling information" do
      expect { extractor.call }.not_to(change { graph.vertices.count })
    end
  end

  describe "logical coupling" do
    let(:options) { { directory:, limit: 100, logical: 1, contributor: 0 } }

    include_context "with a git repository"

    it "constructs a logical coupling graph" do
      extractor.call

      # Extract all vertices with source and destination
      expect(graph.vertices.transform_values { |v| v.edges.transform_values { |es| es.map { |e| e.attributes[:weight] } } }).to eq(
        "App::Foo" => { "App::Bak" => [1], "App::Bat" => [1], "App::Bar" => [1] },
        "App::Bar" => { "App::Foo" => [1] },
        "App::Bat" => { "App::Baz" => [2], "App::Foo" => [1] },
        "App::Bak" => { "App::Foo" => [1] },
        "App::Baz" => { "App::Bat" => [2] },
      )
    end
  end
end
