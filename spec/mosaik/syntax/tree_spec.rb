# frozen_string_literal: true

RSpec.describe MOSAIK::Syntax::Tree do
  subject(:tree) { build(:tree) }

  describe "#[]" do
    it "returns a constant" do
      constant = tree["Foo"]

      expect(constant).to be_a MOSAIK::Syntax::Constant
      expect(constant.name).to eq "Foo"
    end

    it "returns the same constant for the same name" do
      constant1 = tree["Foo"]
      constant2 = tree["Foo"]

      expect(constant1).to eq constant2
    end

    it "returns nested constants" do
      constant = tree["Foo::Bar"]

      expect(constant.name).to eq "Foo::Bar"
    end

    it "stores the constants hierarchically" do
      tree["Foo::Bar"]
      tree["Foo::Baz::Bat"]

      foo = tree["Foo"]

      expect(foo.descendants.map(&:name)).to eq ["Foo::Bar", "Foo::Baz"]
      expect(foo.parent.name).to eq "main"

      foo_bar = tree["Foo::Bar"]
      expect(foo_bar.descendants.map(&:name)).to eq []
      expect(foo_bar.parent.name).to eq "Foo"

      foo_baz = tree["Foo::Baz"]
      expect(foo_baz.descendants.map(&:name)).to eq ["Foo::Baz::Bat"]
      expect(foo_baz.parent.name).to eq "Foo"

      foo_baz_bat = tree["Foo::Baz::Bat"]
      expect(foo_baz_bat.descendants.map(&:name)).to eq []
      expect(foo_baz_bat.parent.name).to eq "Foo::Baz"
    end
  end

  describe "#each" do
    it "yields each constant in depth-first order" do
      tree["Foo"]
      tree["Foo::Bar"]
      tree["Foo::Baz::Bat"]

      constants = tree.map(&:name)

      expect(constants).to eq ["Foo", "Foo::Bar", "Foo::Baz", "Foo::Baz::Bat"]
    end
  end
end
