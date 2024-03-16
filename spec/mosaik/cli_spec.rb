# frozen_string_literal: true

describe MOSAIK::CLI do
  subject(:cli) { described_class.new(args) }

  around { |example| suppress_output { example.run } }

  describe "options" do
    describe "--directory" do
      let(:args) { ["--directory", "/foo/bar/.."] }

      it "sets the working directory" do
        cli

        expect(MOSAIK.options.directory).to eq "/foo"
      end
    end

    describe "--verbose" do
      let(:args) { ["--verbose"] }

      it "turns on verbose output" do
        cli

        expect(MOSAIK.options).to be_verbose
      end
    end

    describe "--debug" do
      let(:args) { ["--debug"] }

      it "turns on debug output" do
        cli

        expect(MOSAIK.options).to be_debug
      end
    end

    describe "--help" do
      let(:args) { ["--help"] }

      it "prints usage and exits" do
        expect { expect { cli }.to raise_error MOSAIK::ExitError }.to log "[global options]"
      end
    end
  end

  describe "#start" do
    let(:args) { ["version", "foo"] }

    context "when no command is given" do
      let(:args) { [] }

      it "prints usage and exits" do
        expect { expect { cli.start }.to raise_error MOSAIK::ExitError }.to log "[global options]"
      end
    end

    it "instantiates a command" do
      expect(MOSAIK::Commands::Version)
        .to receive(:new)
        .with(any_args, "foo")
        .and_call_original

      cli.start
    end

    context "when an invalid command is given" do
      let(:args) { ["foo"] }

      it "prints usage and exits" do
        expect { expect { cli.start }.to raise_error MOSAIK::ExitError }.to log "[global options]"
      end
    end
  end
end
