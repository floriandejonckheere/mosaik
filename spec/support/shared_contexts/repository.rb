# frozen_string_literal: true

RSpec.shared_context "with a git repository" do
  let(:directory) { Dir.mktmpdir }
  let(:git) { Git.init(directory) }

  let(:configuration) { MOSAIK::Configuration.from(File.join(directory, "mosaik.yml")) }

  before do
    # Setup the repository with initial commit
    File.write(File.join(directory, "README.md"), "# Test Repository")
    git.add
    git.commit("Initial commit", author: "Author 1 <author1@example.com>")

    # Add MOSAIK configuration
    FileUtils.cp(MOSAIK.root.join("config/mosaik.yml"), File.join(directory, "mosaik.yml"))
    git.add
    git.commit("Add MOSAIK configuration", author: "Author 1 <author1@example.com>")

    # Add application structure
    FileUtils.mkdir(File.join(directory, "lib"))
    File.write(File.join(directory, "lib/app.rb"), "class App; end")
    git.add
    git.commit("Set up application structure", author: "Author 1 <author1@example.com>")

    # Add classes
    FileUtils.mkdir(File.join(directory, "lib", "app"))
    File.write(File.join(directory, "lib/app/foo.rb"), "class App::Foo; end")
    File.write(File.join(directory, "lib/app/bar.rb"), "class App::Bar; end")
    git.add
    git.commit("Set up application structure", author: "Author 1 <author1@example.com>")

    # Mock the configuration
    allow(MOSAIK)
      .to receive(:configuration)
      .and_return configuration
  end

  after do
    # Cleanup the temporary directory
    FileUtils.remove_entry(directory)
  end
end
