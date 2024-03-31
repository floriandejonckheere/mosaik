# frozen_string_literal: true

RSpec.describe "Repository", :repository do
  include_context "with a git repository"

  it "copies the simulated git repository" do
    FileUtils.mkdir_p MOSAIK.root.join("tmp/repository")

    expect { FileUtils.cp_r File.join(directory, "."), MOSAIK.root.join("tmp/repository") }.not_to raise_error
  end
end
