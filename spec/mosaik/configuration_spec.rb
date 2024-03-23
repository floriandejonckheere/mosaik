# frozen_string_literal: true

RSpec.describe MOSAIK::Configuration do
  subject(:configuration) { described_class.new }

  describe ".from" do
    context "when the configuration file exists" do
      let(:file) { "spec/fixtures/mosaik.yml" }

      it "creates a new configuration instance" do
        expect(described_class.from(file)).to be_a(described_class)
      end

      it "sets the include attribute" do
        expect(described_class.from(file).include).to eq(["foo", "bar"])
      end

      it "sets the exclude attribute" do
        expect(described_class.from(file).exclude).to eq(["baz", "qux"])
      end
    end

    context "when the configuration file does not exist" do
      let(:file) { "spec/fixtures/missing.yml" }

      it "raises an error" do
        expect { described_class.from(file) }.to raise_error(MOSAIK::ConfigurationError, "Configuration file not found: #{file}")
      end
    end
  end
end
