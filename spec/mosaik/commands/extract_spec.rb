# frozen_string_literal: true

RSpec.describe MOSAIK::Commands::Extract do
  subject(:command) { described_class.new(*arguments) }

  let(:arguments) { [] }

  describe "#prepare" do
    describe "--type" do
      it "does not raise an error if the type is valid" do
        allow(File)
          .to receive(:exist?)
          .and_return false

        expect { command.prepare }.not_to raise_error
      end

      context "when the type is invalid" do
        let(:arguments) { ["--type", "invalid"] }

        it "raises an error" do
          expect { command.prepare }.to raise_error(MOSAIK::OptionError, "unknown extraction type: invalid")
        end
      end
    end
  end
end
