# frozen_string_literal: true

RSpec.describe MOSAIK::Commands::Extract do
  subject(:command) { build(:extract_command, arguments:) }

  let(:arguments) { [] }

  describe "#validate" do
    it "does not raise an error" do
      expect { command.validate }.not_to raise_error
    end

    describe "--limit" do
      let(:arguments) { ["--limit", "-1"] }

      it "raises an error" do
        expect { command.validate }.to raise_error(MOSAIK::OptionError, "negative value: -1")
      end
    end
  end
end
