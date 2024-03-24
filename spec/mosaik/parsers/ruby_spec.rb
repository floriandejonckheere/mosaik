# frozen_string_literal: true

RSpec.describe MOSAIK::Parsers::Ruby do
  subject(:parser) { described_class.new }

  let(:file) { "spec/fixtures/lib/app/user.rb" }
  let(:registry) { MOSAIK::Registry.new }

  it "parses constants" do
    parser.parse(file, registry)

    constant = MOSAIK::Constant.new("App::User")

    expect(registry.constants.values).to contain_exactly constant
  end

  it "parses methods" do
    parser.parse(file, registry)

    initialize = MOSAIK::Method.new("initialize", file, 5)
    name = MOSAIK::Method.new("name", file, 11)
    email = MOSAIK::Method.new("email", file, 15)
    admin = MOSAIK::Method.new("admin", file, 19)
    # TODO: admin_ = MOSAIK::Method.new("admin?", file, 23)
    valid_ = MOSAIK::Method.new("valid?", file, 25)
    to_s = MOSAIK::Method.new("to_s", file, 29)

    expect(registry.constants.values.first.methods.values).to eq [initialize, name, email, admin, valid_, to_s]
  end
end
