# frozen_string_literal: true

RSpec.describe MOSAIK::Commands::Extract do
  subject(:command) { build(:extract_command, options:, arguments:) }

  let(:options) { { input: "README.md", output: "doesnotexist.csv" } }
  let(:arguments) { [] }

  describe "#validate" do
    describe "--couplings" do
      let(:arguments) { ["--couplings", "structural,doesnotexist"] }

      it "raises an error" do
        expect { command.validate }.to raise_error MOSAIK::OptionError, "unknown coupling: doesnotexist"
      end
    end

    describe "--limit" do
      let(:arguments) { ["--limit", "-1"] }

      it "raises an error" do
        expect { command.validate }.to raise_error(MOSAIK::OptionError, "negative value: -1")
      end

      context "when the limit is less than 1" do
        let(:arguments) { ["--limit", "0"] }

        it "sets the limit to infinity" do
          command.validate

          expect(command.options[:limit]).to be_nil
        end
      end
    end
  end
end
