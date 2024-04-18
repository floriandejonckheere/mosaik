# frozen_string_literal: true

RSpec.describe MOSAIK::Commands::Evaluate do
  subject(:command) { build(:evaluate_command, arguments:) }

  let(:arguments) { [] }

  describe "#validate" do
    describe "--metrics" do
      let(:arguments) { ["--metrics", "modularity,doesnotexist"] }

      it "raises an error" do
        FileUtils.touch("mosaik-candidates.csv")

        expect { command.validate }.to raise_error MOSAIK::OptionError, "unknown metrics: doesnotexist"
      end
    end
  end
end
