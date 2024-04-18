# frozen_string_literal: true
# typed: true

RSpec.describe MOSAIK::Command do
  describe MOSAIK::Command::Graph do
    subject(:command) { described_class.new(options, *arguments) }

    let(:options) { {} }
    let(:arguments) { [] }

    describe "#validate" do
      describe "--file" do
        let(:arguments) { ["--file", "doesnotexist.csv"] }

        it "raises an error" do
          expect { command.validate }.to raise_error MOSAIK::OptionError, "file not found: doesnotexist.csv"
        end
      end
    end
  end
end
