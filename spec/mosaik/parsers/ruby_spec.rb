# frozen_string_literal: true

RSpec.describe MOSAIK::Parsers::Ruby do
  subject(:parser) { described_class.new }

  let(:file) { "spec/fixtures/lib/app/user.rb" }
  let(:registry) { MOSAIK::Syntax::Registry.new }

  it "parses a Ruby file" do
    parser.parse(file, registry)

    # Test constants
    app = build(:constant, name: "App")
    user = build(:constant, name: "App::User")
    validators = build(:constant, name: "Validators")
    user_validator = build(:constant, name: "Validators::User") # FIXME: fully qualify the constant

    expect(registry).to contain_exactly app, user, validators, user_validator

    # Test methods
    initialize = build(:method, constant: user, name: "initialize")
    name = build(:method, constant: user, name: "name")
    email = build(:method, constant: user, name: "email")
    admin = build(:method, constant: user, name: "admin")
    # TODO: admin_ = build(:method, constant:, "admin?")
    valid_ = build(:method, constant: user, name: "valid?")
    to_s = build(:method, constant: user, name: "to_s")

    expect(registry["App::User"].methods.values).to eq [initialize, name, email, admin, valid_, to_s]

    # Test references
    reference = build(:reference, constant: user_validator, method: "valid?")

    expect(registry["App::User"].methods["valid?"].references).to eq [reference]
  end
end
