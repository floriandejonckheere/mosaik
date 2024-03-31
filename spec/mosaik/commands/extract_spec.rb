# frozen_string_literal: true

RSpec.describe MOSAIK::Commands::Extract do
  subject(:command) { described_class.new(*arguments) }

  let(:arguments) { [] }

  describe "#prepare" do
    it "does not raise an error" do
      expect { command.prepare }.not_to raise_error
    end

    describe "--limit" do
      let(:arguments) { ["--limit", "-1"] }

      it "raises an error" do
        expect { command.prepare }.to raise_error(MOSAIK::OptionError, "negative value: -1")
      end
    end
  end
end
