# frozen_string_literal: true

RSpec.describe MOSAIK::Commands::Extract do
  subject(:command) { build(:extract_command, arguments:) }

  let(:options) { { file: "README.md" } }
  let(:arguments) { [] }

  describe "#validate" do
    describe "--limit" do
      let(:arguments) { ["--limit", "-1"] }

      it "raises an error" do
        expect { command.validate }.to raise_error(MOSAIK::OptionError, "negative value: -1")
      end
    end
  end
end
