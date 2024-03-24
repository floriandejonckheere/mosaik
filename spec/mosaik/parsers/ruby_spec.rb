# frozen_string_literal: true

RSpec.describe MOSAIK::Parsers::Ruby do
  subject(:parser) { described_class.new }

  let(:file) { "spec/fixtures/lib/app/user.rb" }
  let(:registry) { MOSAIK::Registry.new }

  it "parses a Ruby file" do
    parser.parse(file, registry)

    constant = MOSAIK::Constant.new("App::User")

    expect(registry.constants.values).to eq [constant]

    initialize = MOSAIK::Method.new(constant, "initialize", file, 5)
    name = MOSAIK::Method.new(constant, "name", file, 11)
    email = MOSAIK::Method.new(constant, "email", file, 15)
    admin = MOSAIK::Method.new(constant, "admin", file, 19)
    # TODO: admin_ = MOSAIK::Method.new(constant, "admin?", file, 23)
    valid_ = MOSAIK::Method.new(constant, "valid?", file, 25)
    to_s = MOSAIK::Method.new(constant, "to_s", file, 29)

    expect(registry.constants.values.first.methods.values).to eq [initialize, name, email, admin, valid_, to_s]
  end
end
