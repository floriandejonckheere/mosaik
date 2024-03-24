# frozen_string_literal: true

module MOSAIK
  class Registry
    include Enumerable
    def [](constant_path)
      # Split constant path by ::
      current_hierarchy = hierarchy
      current_constant = nil

      constant_path.split("::").inject(nil) do |fully_qualified_constant_name, constant_name|
        # Generate fully qualified constant name
        fully_qualified_constant_name = [fully_qualified_constant_name, constant_name].compact.join("::")

        # Look up or create constant
        current_constant, descendants = current_hierarchy[fully_qualified_constant_name] ||= [Constant.new(fully_qualified_constant_name), {}]

        # Descend into hierarchy
        current_hierarchy = descendants

        fully_qualified_constant_name
      end

      current_constant
    end

    def each(&)
      dfs(hierarchy, &)
    end

    private

    def hierarchy
      # { "Foo" => [#<Constant "Foo">, { "Bar" => [#<Constant "Foo::Bar">, {}], "Baz" => [#<Constant "Foo::Baz">, {}] }] }
      @hierarchy ||= {}
    end

    def dfs(hierarchy, &block)
      hierarchy.each_value do |(constant, descendants)|
        yield constant

        dfs(descendants, &block)
      end
    end
  end
end
