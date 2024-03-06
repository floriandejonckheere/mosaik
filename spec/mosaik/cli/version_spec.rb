# frozen_string_literal: true

RSpec.describe MOSAIK::CLI::Version do
  subject(:command) { described_class.new(options) }

  let(:options) { {} }

  it "prints the version" do
    expect { command.call }
      .to output("MOSAIK #{MOSAIK::VERSION}\n")
      .to_stdout
  end
end
