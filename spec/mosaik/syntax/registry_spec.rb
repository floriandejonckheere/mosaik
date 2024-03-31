# frozen_string_literal: true

RSpec.describe MOSAIK::Syntax::Registry do
  subject(:registry) { described_class.new }

  describe "#[]" do
    it "returns a constant" do
      constant = registry["Foo"]

      expect(constant).to be_a MOSAIK::Syntax::Constant
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

    it "stores the constants hierarchically" do
      registry["Foo::Bar"]
      registry["Foo::Baz::Bat"]

      foo = registry["Foo"]

      expect(foo.descendants.map(&:name)).to eq ["Foo::Bar", "Foo::Baz"]
      expect(foo.parent.name).to be_nil

      foo_bar = registry["Foo::Bar"]
      expect(foo_bar.descendants.map(&:name)).to eq []
      expect(foo_bar.parent.name).to eq "Foo"

      foo_baz = registry["Foo::Baz"]
      expect(foo_baz.descendants.map(&:name)).to eq ["Foo::Baz::Bat"]
      expect(foo_baz.parent.name).to eq "Foo"

      foo_baz_bat = registry["Foo::Baz::Bat"]
      expect(foo_baz_bat.descendants.map(&:name)).to eq []
      expect(foo_baz_bat.parent.name).to eq "Foo::Baz"
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
