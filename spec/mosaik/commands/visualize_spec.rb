# frozen_string_literal: true

RSpec.describe MOSAIK::Commands::Visualize do
  subject(:command) { build(:visualize_command, options:, arguments:) }

  let(:options) { { file: "mosaik.csv" } }
  let(:arguments) { [] }

  describe "#validate" do
    describe "--input" do
      let(:arguments) { ["--input", "doesnotexist.csv"] }

      it "raises an error" do
        expect { command.validate }.to raise_error MOSAIK::OptionError, "input file not found: doesnotexist.csv"
      end
    end
  end
end
