# frozen_string_literal: true
# typed: true

RSpec.describe MOSAIK::Command do
  describe MOSAIK::Command::Graph do
    subject(:command) { described_class.new(options, *arguments) }

    let(:options) { { input: "README.md", output: "doesnotexist.csv" } }
    let(:arguments) { [] }

    describe "#validate" do
      describe "--output" do
        let(:arguments) { ["--output", "README.md"] }

        it "raises an error" do
          expect { command.validate }.to raise_error MOSAIK::OptionError, "output file exists: README.md"
        end
      end

      describe "--visualize" do
        let(:arguments) { ["--visualize"] }

        it "turns on visualizations" do
          command.validate

          expect(command.options[:visualize]).to be true
        end
      end

      describe "--renderer" do
        let(:arguments) { ["--renderer", "invalid"] }

        it "raises an error" do
          expect { command.validate }.to raise_error MOSAIK::OptionError, "unknown renderer: invalid"
        end
      end
    end

    describe "--format" do
      let(:arguments) { ["--format", "invalid"] }

      it "raises an error" do
        expect { command.validate }.to raise_error MOSAIK::OptionError, "unknown format: invalid"
      end
    end
  end
end
