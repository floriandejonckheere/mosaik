# frozen_string_literal: true

RSpec.describe MOSAIK::Commands::Visualize do
  subject(:command) { build(:visualize_command, options:, arguments:) }

  let(:options) { { input: "README.md" } }
  let(:arguments) { [] }

  describe "#validate" do
    describe "--input" do
      let(:arguments) { ["--input", "doesnotexist.csv"] }

      it "raises an error" do
        expect { command.validate }.to raise_error MOSAIK::OptionError, "input file not found: doesnotexist.csv"
      end
    end

    it "forces visualization" do
      command.validate

      expect(command.options[:visualize]).to be true
    end

    it "removes output file extension" do
      command.validate

      expect(command.options[:output]).to eq "mosaik"
    end
  end
end
