# frozen_string_literal: true

describe MOSAIK::CLI do
  subject(:cli) { described_class.new(args) }

  describe "options" do
    describe "--directory" do
      let(:args) { ["--directory", "/foo/bar/.."] }

      it "sets the working directory" do
        cli

        expect(cli.options[:directory]).to eq "/foo"
      end
    end

    describe "--verbose" do
      let(:args) { ["--verbose"] }

      it "turns on verbose output" do
        cli

        expect(cli.options[:verbose]).to be true
      end
    end

    describe "--debug" do
      let(:args) { ["--debug"] }

      it "turns on debug output" do
        cli

        expect(cli.options[:debug]).to be true
      end
    end

    describe "--help" do
      let(:args) { ["--help"] }

      it "prints usage and exits" do
        expect { expect { cli }.to raise_error MOSAIK::ExitError }.to log "[global options]"
      end
    end
  end

  describe "#validate" do
    let(:args) { ["version"] }

    context "when the directory does not exist" do
      let(:args) { ["--directory", "/foo"] }

      it "raises an error" do
        expect { expect { cli.validate }.to raise_error MOSAIK::ExitError }.to log "invalid directory: /foo"
      end
    end

    context "when the directory is not a directory" do
      let(:args) { ["--directory", __FILE__] }

      it "raises an error" do
        expect { expect { cli.validate }.to raise_error MOSAIK::ExitError }.to log "not a directory: #{__FILE__}"
      end
    end
  end

  describe "#call" do
    let(:args) { ["version", "foo"] }

    context "when no command is given" do
      let(:args) { [] }

      it "prints usage and exits" do
        expect { expect { cli.call }.to raise_error MOSAIK::ExitError }.to log "[global options]"
      end
    end

    it "instantiates a command" do
      expect(MOSAIK::Commands::Version)
        .to receive(:new)
        .with(any_args, "foo")
        .and_call_original

      cli.call
    end

    context "when an invalid command is given" do
      let(:args) { ["foo"] }

      it "prints usage and exits" do
        expect { expect { cli.call }.to raise_error MOSAIK::ExitError }.to log "[global options]"
      end
    end
  end
end
