# frozen_string_literal: true

RSpec.describe MOSAIK::Command do
  let(:command_class) do
    Class.new(described_class) do
      self.description = "A command"

      defaults number: 1,
               a_string: "a string",
               boolean: false

      argument "--number NUMBER", Integer, "Number argument"
      argument "--a-string A_STRING", "A string argument"
      argument "--boolean", "Boolean argument"

      def self.name
        "MOSAIK::Commands::Test"
      end
    end
  end

  it "has a description" do
    expect(command_class.description).to eq "A command"
  end

  describe "#initialize" do
    it "parses command arguments" do
      command = command_class.new("--number", "2", "--a-string", "another string", "--boolean")

      expect(command.options).to eq number: 2, a_string: "another string", boolean: true
    end
  end
end
