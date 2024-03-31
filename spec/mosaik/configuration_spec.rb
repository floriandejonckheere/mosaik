# frozen_string_literal: true

RSpec.describe MOSAIK::Configuration do
  subject(:configuration) { described_class.new(directory: "/tmp", load_paths: ["lib"], includes: ["*.rb"], excludes: ["vendor"], overrides: { "foobar" => "FooBar" }) }

  describe "#files" do
    it "returns only included files" do
      allow(Dir)
        .to receive(:[])
        .and_call_original

      allow(Dir)
        .to receive(:[])
        .with("/tmp/lib/*.rb")
        .and_return ["/tmp/lib/foo.rb", "/tmp/lib/bar.rb", "/tmp/lib/vendor/baz.rb"]

      allow(Dir)
        .to receive(:[])
        .with("/tmp/lib/vendor")
        .and_return ["/tmp/lib/vendor/baz.rb"]

      expect(configuration.files).to eq ["/tmp/lib/foo.rb", "/tmp/lib/bar.rb"]
    end
  end

  describe ".from" do
    context "when the configuration file exists" do
      let(:file) { MOSAIK.root.join("spec/fixtures/mosaik.yml") }

      it "creates a new configuration instance" do
        expect(described_class.from(file)).to be_a described_class
      end

      it "sets the load_paths attribute" do
        expect(described_class.from(file).load_paths).to eq ["lib"]
      end

      it "sets the includes attribute" do
        expect(described_class.from(file).includes).to eq ["**/*.{rb,rake,erb}"]
      end

      it "sets the excludes attribute" do
        expect(described_class.from(file).excludes).to eq ["{bin,node_modules,script,tmp,vendor}/**/*"]
      end

      it "sets the overrides attribute" do
        expect(described_class.from(file).overrides).to eq "foobar" => "FooBar"
      end
    end

    context "when the configuration file does not exist" do
      let(:file) { "spec/fixtures/missing.yml" }

      it "raises an error" do
        expect { described_class.from(file) }.to raise_error MOSAIK::ConfigurationError, "Configuration file not found: #{file}"
      end
    end
  end
end
