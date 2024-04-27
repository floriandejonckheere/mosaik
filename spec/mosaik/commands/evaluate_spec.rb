# frozen_string_literal: true

RSpec.describe MOSAIK::Commands::Evaluate do
  subject(:command) { build(:evaluate_command, options:, arguments:) }

  let(:options) { { input: "README.md" } }
  let(:arguments) { [] }

  describe "#validate" do
    describe "--input" do
      let(:arguments) { ["--input", "doesnotexist.csv"] }

      it "raises an error" do
        expect { command.validate }.to raise_error MOSAIK::OptionError, "input file not found: doesnotexist.csv"
      end
    end

    describe "--metrics" do
      let(:arguments) { ["--metrics", "modularity,doesnotexist"] }

      it "raises an error" do
        expect { command.validate }.to raise_error MOSAIK::OptionError, "unknown metrics: doesnotexist"
      end
    end
  end
end
