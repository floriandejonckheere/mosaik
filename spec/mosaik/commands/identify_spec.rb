# frozen_string_literal: true

RSpec.describe MOSAIK::Commands::Identify do
  subject(:command) { build(:identify_command, options:, arguments:) }

  let(:options) { { input: "README.md" } }
  let(:arguments) { [] }

  describe "#validate" do
    describe "--input" do
      let(:arguments) { ["--input", "doesnotexist.csv"] }

      it "raises an error" do
        expect { command.validate }.to raise_error MOSAIK::OptionError, "input file not found: doesnotexist.csv"
      end
    end

    describe "--algorithm" do
      let(:arguments) { ["--algorithm", "invalid"] }

      it "raises an error" do
        expect { command.validate }.to raise_error MOSAIK::OptionError, "unknown algorithm: invalid"
      end
    end
  end
end
