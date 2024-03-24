# frozen_string_literal: true

RSpec.describe MOSAIK::Registry do
  subject(:registry) { described_class.new }

  describe "#[]" do
    it "returns a constant" do
      constant = registry["Foo"]

      expect(constant).to be_a MOSAIK::Constant
      expect(constant.name).to eq "Foo"
    end

    it "returns the same constant for the same name" do
      constant1 = registry["Foo"]
      constant2 = registry["Foo"]

      expect(constant1).to eq constant2
    end

    it "returns nested constants" do
      constant = registry["Foo::Bar"]

      expect(constant.name).to eq "Foo::Bar"
    end
  end

  describe "#each" do
    it "yields each constant in depth-first order" do
      registry["Foo"]
      registry["Foo::Bar"]
      registry["Foo::Baz::Bat"]

      constants = []
      registry.each { |constant| constants << constant.name }

      expect(constants).to eq ["Foo", "Foo::Bar", "Foo::Baz", "Foo::Baz::Bat"]
    end
  end
end
