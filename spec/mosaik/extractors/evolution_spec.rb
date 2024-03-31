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
      expect(graph.vertices.transform_values { |v| v.edges.keys }).to eq(
        "App::Foo" => ["App::Bak", "App::Bat", "App::Bar"],
        "App::Bar" => ["App::Foo"],
        "App::Bat" => ["App::Baz", "App::Foo"],
        "App::Bak" => ["App::Foo"],
        "App::Baz" => ["App::Bat"]
      )
    end
  end
end
