# frozen_string_literal: true

RSpec.describe MOSAIK::Extractors::Evolution do
  subject(:extractor) { described_class.new(options, graph) }

  let(:options) { { directory: MOSAIK.root, logical: 1, contributor: 1 } }
  let(:graph) { build(:graph) }

  let(:configuration) { build(:configuration) }

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
end
