# frozen_string_literal: true

RSpec.describe MOSAIK::Resolver do
  subject(:resolver) { described_class.new(directory, load_paths) }

  describe "#resolve" do
    let(:directory) { "/tmp" }
    let(:load_paths) { ["lib", "app"] }

    it "resolves file paths to constant names" do
      expect(resolver.resolve("lib/mosaik.rb"))
        .to eq("Mosaik")

      expect(resolver.resolve("lib/mosaik/version.rb"))
        .to eq("Mosaik::Version")

      expect(resolver.resolve("app/user.rb"))
        .to eq("User")

      expect(resolver.resolve("app/users/user.rb"))
        .to eq("Users::User")
    end

    it "resolves file paths with custom overrides" do
      resolver.override("mosaik" => "MOSAIK")

      expect(resolver.resolve("lib/mosaik/version.rb"))
        .to eq("MOSAIK::Version")
    end

    it "does not resolve file paths outside of the load paths" do
      expect(resolver.resolve("tmp/mosaik.rb"))
        .to be_nil

      expect(resolver.resolve("mosaik.rb"))
        .to be_nil
    end
  end
end
