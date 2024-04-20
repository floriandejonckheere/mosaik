# frozen_string_literal: true

module MOSAIK
  module Syntax
    ##
    # Tree of constants in the codebase
    #
    class Tree
      include Enumerable

      attr_reader :top

      def initialize
        # Create a top-level constant to represent the root of the hierarchy
        @top = Constant.new("main")
      end

      def [](constant_path)
        current_constant = top

        # Split constant path by ::
        constant_path.split("::").inject(nil) do |fully_qualified_constant_name, constant_name|
          # Generate fully qualified constant name
          fully_qualified_constant_name = [fully_qualified_constant_name, constant_name].compact.join("::")

          # Look up or create constant
          next_constant = current_constant.descendants.find { |c| c.name == fully_qualified_constant_name }
          next_constant ||= Constant.new(fully_qualified_constant_name, current_constant)

          # Add constant to hierarchy
          current_constant.descendants << next_constant

          # Descend into the next constant
          current_constant = next_constant

          fully_qualified_constant_name
        end

        current_constant
      end

      def each(&)
        dfs(top, &)
      end

      def dfs(constant, &block)
        constant.descendants.each do |descendant|
          yield descendant

          dfs(descendant, &block)
        end
      end
    end
  end
end
