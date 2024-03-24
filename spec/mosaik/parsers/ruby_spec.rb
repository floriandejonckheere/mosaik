# frozen_string_literal: true

RSpec.describe MOSAIK::Parsers::Ruby do
  subject(:parser) { described_class.new }

  let(:file) { "spec/fixtures/lib/app/user.rb" }
  let(:registry) { MOSAIK::Registry.new }

  it "parses a Ruby file" do
    parser.parse(file, registry)

    constant = MOSAIK::Constant.new("App::User")

    expect(registry.constants.values).to contain_exactly constant

    initialize = MOSAIK::Method.new("initialize", file, 7)
    to_s = MOSAIK::Method.new("to_s", file, 15)

    expect(registry.constants.values.first.methods).to contain_exactly initialize, to_s
  end
end
