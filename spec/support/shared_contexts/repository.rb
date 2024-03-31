# frozen_string_literal: true

RSpec.shared_context "with a git repository" do
  let(:directory) { Dir.mktmpdir }
  let(:git) { Git.init(directory) }

  let(:configuration) { MOSAIK::Configuration.from(File.join(directory, "mosaik.yml")) }

  let(:john) { "John Doe <john@example.com>" }
  let(:jane) { "Jane Doe <jane@example.com>" }
  let(:joey) { "Joey Doe <joey@example.com>" }

  def commit(author, **files_with_content)
    # Write the files with content
    files_with_content.each do |file, content|
      FileUtils.mkdir_p(File.join(directory, File.dirname(file)))
      File.write(File.join(directory, file), content)
    end

    # Add and commit the files
    git.add
    git.commit("Add #{files_with_content.keys.join(', ')}", author:)
  end

  before do
    # Set up committer configuration
    git.config("user.name", "Author 1")
    git.config("user.email", "john@example.com")

    # Setup the repository with initial commit
    commit john,
           "README.md" => "# Test Repository"

    # Add MOSAIK configuration
    commit john,
           "mosaik.yml" => File.read(MOSAIK.root.join("config/mosaik.yml"))

    # Add application structure
    commit john,
           "lib/app.rb" => "class App; end"

    # Add classes
    commit john,
           "lib/app/foo.rb" => "class App::Foo; end",
           "lib/app/bar.rb" => "class App::Bar; end"

    commit jane,
           "lib/app/foo.rb" => "class App::Foo; def initialize; end; end",
           "lib/app/bat.rb" => "class App::Bat; end"

    commit john,
           "lib/app/foo.rb" => "class App::Foo; end",
           "lib/app/bak.rb" => "class App::Bak; end"

    commit jane,
           "lib/app/bat.rb" => "class App::Bat; def initialize; end; end",
           "lib/app/baz.rb" => "class App::Baz; end"

    commit john,
           "lib/app/bat.rb" => "class App::Bat; end",
           "lib/app/baz.rb" => "class App::Baz; def initialize; end; end"

    commit joey,
           "lib/app/bat.rb" => "class App::Bat; def initialize; end; end",
           "lib/app/baz.rb" => "class App::Baz; end"

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
