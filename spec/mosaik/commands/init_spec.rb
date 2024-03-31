# frozen_string_literal: true

RSpec.describe MOSAIK::Commands::Init do
  subject(:command) { build(:init_command, options:) }

  let(:options) { { directory: Dir.mktmpdir } }

  it "writes a configuration file" do
    command.call

    expect(File).to exist File.join(options[:directory], "mosaik.yml")
  end

  context "when the configuration file already exists" do
    before { FileUtils.touch File.join(options[:directory], "mosaik.yml") }

    it "raises an error" do
      expect { command.call }.to raise_error(MOSAIK::ConfigurationError, /Configuration file already exists at/)
    end
  end
end
