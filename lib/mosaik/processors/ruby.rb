# frozen_string_literal: true

module MOSAIK
  module Processors
    class Ruby < AST::Processor
      attr_reader :file, :registry
      attr_accessor :current_class

      def initialize(file, registry)
        super()

        @file = file
        @registry = registry
      end

      def on_class(node)
        class_name = node.children[0].children[1].to_s

        # Build fully qualified class name
        self.current_class = current_class ? "#{current_class}::#{class_name}" : class_name

        # Traverse the AST
        node.children.each { |c| process(c) }

        # Reset current class
        self.current_class = current_class.sub("::#{class_name}", "") if current_class.include?("::")
      end

      def on_module(node)
        module_name = node.children[0].children[1].to_s

        # Build fully qualified class name
        self.current_class = current_class ? "#{current_class}::#{module_name}" : module_name

        # Traverse the AST
        node.children.each { |c| process(c) }

        # Reset current class
        self.current_class = current_class.sub(module_name, "")
      end

      # Instance methods
      def on_def(node)
        line_num = node.loc.line
        method_name = node.children[0]

        registry.constants[current_class].methods << Method.new(method_name.to_s, file, line_num)
      end

      # Class methods
      def on_defs(node)
        line_num = node.loc.line
        method_name = "self.#{node.children[1]}"

        registry.constants[current_class].methods << Method.new(method_name.to_s, file, line_num)
      end

      def on_begin(node)
        node.children.each { |c| process(c) }
      end
    end
  end
end
