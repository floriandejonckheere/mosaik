# frozen_string_literal: true

RSpec.describe MOSAIK::CLI::Collect do
  subject(:command) { described_class.new(options) }

  let(:options) { {} }

  it "prints the status" do
    expect { command.call }
      .to output("Starting data collection...\n")
      .to_stdout
  end
end
