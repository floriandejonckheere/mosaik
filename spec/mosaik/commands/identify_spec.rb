# frozen_string_literal: true

RSpec.describe MOSAIK::Commands::Identify do
  subject(:command) { build(:identify_command, arguments:) }

  let(:arguments) { [] }

  describe "#validate" do
    it "does not raise an error" do
      FileUtils.touch("mosaik.csv")

      expect { command.validate }.not_to raise_error
    end

    describe "--file" do
      let(:arguments) { ["--file", "doesnotexist.csv"] }

      it "raises an error" do
        expect { command.validate }.to raise_error MOSAIK::OptionError, "file not found: doesnotexist.csv"
      end
    end
  end
end
