# frozen_string_literal: true

RSpec.describe MOSAIK::Commands::Init do
  subject(:command) { build(:init_command) }

  around do |example|
    Dir.mktmpdir do |dir|
      MOSAIK.options.directory = dir

      example.run
    end
  end

  it "writes a configuration file" do
    command.start

    expect(File).to exist File.join(MOSAIK.options.directory, "mosaik.yml")
  end

  context "when the configuration file already exists" do
    before { FileUtils.touch File.join(MOSAIK.options.directory, "mosaik.yml") }

    it "raises an error" do
      expect { command.start }.to raise_error(MOSAIK::ConfigurationError, /Configuration file already exists at/)
    end
  end
end
