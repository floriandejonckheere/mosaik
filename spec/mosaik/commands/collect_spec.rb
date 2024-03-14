# frozen_string_literal: true

RSpec.describe MOSAIK::Commands::Collect do
  subject(:command) { build(:collect_command) }

  it "shows the current application version" do
    expect { command.start }.to log(/Starting data collection.../o)
  end
end
