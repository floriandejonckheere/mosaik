# frozen_string_literal: true

RSpec.describe MOSAIK::Commands::Collect do
  subject(:command) { described_class.new(*arguments) }

  let(:arguments) { [] }

  it "has a default output file" do
    expect(command.options[:output]).to eq("mosaik.dot")
  end

  describe "#prepare" do
    describe "--output" do
      it "does not raise an error if the output file does not exist" do
        expect { command.prepare }.not_to raise_error
      end

      context "when the output file exists" do
        it "raises an error" do
          allow(File)
            .to receive(:exist?)
            .and_return true

          expect { command.prepare }.to raise_error(MOSAIK::OptionError, "file already exists: mosaik.dot, use --force to overwrite")
        end

        context "when the force option is set" do
          let(:arguments) { ["--force"] }

          it "does not raise an error" do
            allow(File)
              .to receive(:exist?)
              .and_return true

            expect { command.prepare }.not_to raise_error
          end
        end
      end
    end
  end
end
