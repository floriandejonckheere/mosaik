# frozen_string_literal: true

RSpec.describe MOSAIK::Resolver do
  subject(:resolver) { described_class.new(directory, load_paths) }

  let(:directory) { Dir.mktmpdir }
  let(:load_paths) { ["lib", "app"] }

  before do
    # Create a temporary directory structure
    FileUtils.mkdir_p("#{directory}/lib/mosaik")
    FileUtils.touch("#{directory}/lib/mosaik.rb")
    FileUtils.touch("#{directory}/lib/mosaik/version.rb")

    FileUtils.touch("#{directory}/lib/foo_bar.rb")

    FileUtils.mkdir_p("#{directory}/lib/core_ext")
    FileUtils.touch("#{directory}/lib/core_ext/object.rb")

    FileUtils.mkdir_p("#{directory}/lib/concerns")
    FileUtils.touch("#{directory}/lib/concerns/arguments.rb")

    FileUtils.mkdir_p("#{directory}/app")
    FileUtils.touch("#{directory}/app/user.rb")
    FileUtils.mkdir_p("#{directory}/app/users")
    FileUtils.touch("#{directory}/app/users/user.rb")
  end

  describe "#resolve_file" do
    it "resolves relative file paths to constant names" do
      expect(resolver.resolve_file("lib/mosaik.rb"))
        .to eq("Mosaik")

      expect(resolver.resolve_file("lib/mosaik/version.rb"))
        .to eq("Mosaik::Version")

      expect(resolver.resolve_file("lib/foo_bar.rb"))
        .to eq("FooBar")

      expect(resolver.resolve_file("lib/core_ext"))
        .to eq("CoreExt")

      expect(resolver.resolve_file("lib/core_ext/object.rb"))
        .to eq("CoreExt::Object")

      expect(resolver.resolve_file("app/user.rb"))
        .to eq("User")

      expect(resolver.resolve_file("app/users/user.rb"))
        .to eq("Users::User")
    end

    it "resolves absolute file paths to constant names" do
      expect(resolver.resolve_file("#{directory}/lib/mosaik.rb"))
        .to eq("Mosaik")

      expect(resolver.resolve_file("#{directory}/lib/mosaik/version.rb"))
        .to eq("Mosaik::Version")

      expect(resolver.resolve_file("#{directory}/lib/foo_bar.rb"))
        .to eq("FooBar")

      expect(resolver.resolve_file("#{directory}/lib/core_ext"))
        .to eq("CoreExt")

      expect(resolver.resolve_file("#{directory}/lib/core_ext/object.rb"))
        .to eq("CoreExt::Object")

      expect(resolver.resolve_file("#{directory}/app/user.rb"))
        .to eq("User")

      expect(resolver.resolve_file("#{directory}/app/users/user.rb"))
        .to eq("Users::User")
    end

    it "resolves file paths with custom overrides" do
      resolver.override("mosaik" => "MOSAIK")

      expect(resolver.resolve_file("lib/mosaik/version.rb"))
        .to eq("MOSAIK::Version")

      expect(resolver.resolve_file("#{directory}/lib/mosaik/version.rb"))
        .to eq("MOSAIK::Version")
    end

    it "resolves file paths with collapsed directories" do
      resolver.collapse("lib/concerns")

      expect(resolver.resolve_file("lib/concerns/arguments.rb"))
        .to eq("Arguments")
    end

    it "does not resolve file paths outside of the load paths" do
      expect(resolver.resolve_file("tmp/mosaik.rb"))
        .to be_nil

      expect(resolver.resolve_file("mosaik.rb"))
        .to be_nil

      expect(resolver.resolve_file("/var/mosaik.rb"))
        .to be_nil
    end
  end

  describe "#resolve_constant" do
    it "resolves constant names to absolute file or directory paths" do
      expect(resolver.resolve_constant("Mosaik"))
        .to eq "#{directory}/lib/mosaik.rb"

      expect(resolver.resolve_constant("Mosaik::Version"))
        .to eq "#{directory}/lib/mosaik/version.rb"

      expect(resolver.resolve_constant("FooBar"))
        .to eq "#{directory}/lib/foo_bar.rb"

      expect(resolver.resolve_constant("CoreExt"))
        .to eq "#{directory}/lib/core_ext"

      expect(resolver.resolve_constant("CoreExt::Object"))
        .to eq "#{directory}/lib/core_ext/object.rb"

      expect(resolver.resolve_constant("User"))
        .to eq "#{directory}/app/user.rb"

      expect(resolver.resolve_constant("Users::User"))
        .to eq "#{directory}/app/users/user.rb"
    end

    it "resolves constant names with custom overrides" do
      resolver.override("mosaik" => "MOSAIK", "foo_bar" => "Foobar")

      expect(resolver.resolve_constant("MOSAIK::Version"))
        .to eq("#{directory}/lib/mosaik/version.rb")

      expect(resolver.resolve_constant("Foobar"))
        .to eq("#{directory}/lib/foo_bar.rb")
    end

    it "resolves constant names with collapsed directories" do
      resolver.collapse("lib/concerns")

      expect(resolver.resolve_constant("Arguments"))
        .to eq("#{directory}/lib/concerns/arguments.rb")
    end

    it "does not resolve constant names that do not exist" do
      expect(resolver.resolve_constant("Tmp::Mosaik"))
        .to be_nil

      expect(resolver.resolve_constant("Mosaik::Tmp"))
        .to be_nil
    end
  end

  describe "#resolve_file!" do
    it "raises an error when a file cannot be resolved" do
      expect { resolver.resolve_file!("tmp/mosaik.rb") }
        .to raise_error MOSAIK::ResolveError
    end
  end

  describe "#resolve_constant!" do
    it "raises an error when a constant cannot be resolved" do
      expect { resolver.resolve_constant!("Tmp::MOSAIK") }
        .to raise_error MOSAIK::ResolveError
    end
  end

  describe "#underscore" do
    it "converts camel case to snake case" do
      expect(resolver.send(:underscore, "Foo")).to eq "foo"
      expect(resolver.send(:underscore, "FooBar")).to eq "foo_bar"
      expect(resolver.send(:underscore, "FOOBAR")).to eq "foobar"
      expect(resolver.send(:underscore, "Foo9000")).to eq "foo_9000"
    end

    it "respects custom overrides" do
      resolver.override("foobar" => "FooBar", "foo" => "FOO")

      expect(resolver.send(:underscore, "FooBar")).to eq "foobar"
      expect(resolver.send(:underscore, "FOO")).to eq "foo"
    end
  end
end
