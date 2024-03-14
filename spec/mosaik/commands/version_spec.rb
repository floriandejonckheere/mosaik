# frozen_string_literal: true

RSpec.describe MOSAIK::Commands::Version do
  subject(:command) { build(:version_command) }

  it "shows the current application version" do
    expect { command.start }.to log(/MOSAIK #{MOSAIK::VERSION}/o)
  end
end
