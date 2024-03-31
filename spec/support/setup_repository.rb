# frozen_string_literal: true

# Relative path to the repository
DIRECTORY = "tmp/repository"

# Committers
john = "John Doe <john@example.com>"
jane = "Jane Doe <jane@example.com>"
joey = "Joey Doe <joey@example.com>"

# Cleanup the temporary repository directory
FileUtils.remove_entry(DIRECTORY)

# Initialize the repository
GIT = Git.init(DIRECTORY)

# Set up committer configuration
GIT.config("user.name", "John Doe")
GIT.config("user.email", "john@example.com")

def commit(author, **files_with_content)
  # Write the files with content
  files_with_content.each do |file, content|
    FileUtils.mkdir_p(File.join(DIRECTORY, File.dirname(file)))
    File.write(File.join(DIRECTORY, file), content)
  end

  # Add and commit the files
  GIT.add
  GIT.commit("Add #{files_with_content.keys.join(', ')}", author:)
end

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

RSpec.configure do |config|
  config.before do
    configuration = MOSAIK::Configuration.from(File.join(DIRECTORY, "mosaik.yml"))

    # Mock the configuration
    allow(MOSAIK)
      .to receive(:configuration)
      .and_return configuration
  end
end
