# frozen_string_literal: true

RSpec.describe MOSAIK::Registry do
  subject(:registry) { described_class.new }

  describe "#[]" do
    it "returns a constant" do
      constant = registry["Foo"]

      expect(constant).to be_a MOSAIK::Constant
      expect(constant.name).to eq("Foo")
    end

    it "returns the same constant for the same name" do
      constant1 = registry["Foo"]
      constant2 = registry["Foo"]

      expect(constant1).to eq constant2
    end

    it "registers the constant in the hierarchy" do
      registry["Foo::Bar"]

      expect(registry.hierarchy).to eq({ "Foo" => { "Bar" => {} } })
    end
  end
end
