# frozen_string_literal: true

RSpec.describe MOSAIK::Resolver do
  subject(:resolver) { described_class.new(directory, load_paths) }

  let(:directory) { "/tmp" }
  let(:load_paths) { ["lib", "app"] }

  describe "#resolve" do
    it "resolves relative file paths to constant names" do
      expect(resolver.resolve("lib/mosaik.rb"))
        .to eq("Mosaik")

      expect(resolver.resolve("lib/mosaik/version.rb"))
        .to eq("Mosaik::Version")

      expect(resolver.resolve("app/user.rb"))
        .to eq("User")

      expect(resolver.resolve("app/users/user.rb"))
        .to eq("Users::User")
    end

    it "resolves absolute file paths to constant names" do
      expect(resolver.resolve("/tmp/lib/mosaik.rb"))
        .to eq("Mosaik")

      expect(resolver.resolve("/tmp/lib/mosaik/version.rb"))
        .to eq("Mosaik::Version")

      expect(resolver.resolve("/tmp/app/user.rb"))
        .to eq("User")

      expect(resolver.resolve("/tmp/app/users/user.rb"))
        .to eq("Users::User")
    end

    it "resolves file paths with custom overrides" do
      resolver.override("mosaik" => "MOSAIK")

      expect(resolver.resolve("lib/mosaik/version.rb"))
        .to eq("MOSAIK::Version")

      expect(resolver.resolve("/tmp/lib/mosaik/version.rb"))
        .to eq("MOSAIK::Version")
    end

    it "does not resolve file paths outside of the load paths" do
      expect(resolver.resolve("tmp/mosaik.rb"))
        .to be_nil

      expect(resolver.resolve("mosaik.rb"))
        .to be_nil

      expect(resolver.resolve("/var/mosaik.rb"))
        .to be_nil
    end
  end

  describe "#resolve!" do
    it "raises an error when a file cannot be resolved" do
      expect { resolver.resolve!("tmp/mosaik.rb") }
        .to raise_error MOSAIK::ResolveError
    end
  end
end
