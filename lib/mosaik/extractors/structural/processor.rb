# frozen_string_literal: true

module MOSAIK
  module Extractors
    class Structural
      ##
      # Abstract Syntax Tree parser for Ruby code
      #
      class Processor < AST::Processor
        # Magic value for root namespace
        MAIN = "(main)"

        # Ignorelist for constants
        IGNORE_CONSTANTS = ["ENV", "T", "File", "FileUtils"].freeze

        # Ignorelist for methods
        IGNORE_METHODS = ["require", "new", "include", "extend", "delegate", "public", "private", "protected", "raise", "attr_reader", "attr_writer", "attr_accessor"].freeze

        attr_reader :tree
        attr_accessor :current_class, :current_method

        def initialize(tree)
          super()

          @tree = tree
          @current_class = MAIN
        end

        def on_class(node)
          class_name = constant_name_from(node.children[0])

          # Build fully qualified class name
          self.current_class = current_class == MAIN ? class_name : [current_class, class_name].join("::")

          # Register class
          tree[current_class]

          debug "Class #{current_class} in #{node.loc.expression.source_buffer.name}:#{node.loc.line}"

          # Traverse the AST
          node.children.each { |c| process(c) }

          # Remove current class from the namespace
          self.current_class = current_class
            .split("::")
            .tap { |c| c.delete(class_name) }
            .join("::")
            .presence || MAIN
        end

        def on_module(node)
          module_name = constant_name_from(node.children[0])

          # Build fully qualified class name
          self.current_class = current_class == MAIN ? module_name : [current_class, module_name].join("::")

          # Register module
          tree[current_class]

          debug "Module #{current_class} in #{node.loc.expression.source_buffer.name}:#{node.loc.line}"

          # Traverse the AST
          node.children.each { |c| process(c) }

          # Remove current module from the namespace
          self.current_class = current_class
            .split("::")
            .tap { |c| c.delete(module_name) }
            .join("::")
            .presence || MAIN
        end

        # Instance methods
        def on_def(node)
          method_name = node.children[0].to_s
          file = node.loc.expression.source_buffer.name
          line_num = node.loc.line

          # Set current method
          self.current_method = method_name

          debug "Class instance method #{current_class}##{method_name} in #{file}:#{line_num}"

          tree[current_class].add_method(method_name, file, line_num)

          # Traverse the AST (first two children are method name and arguments)
          node.children[2..].each { |c| process(c) }

          # Reset current method
          self.current_method = nil
        end

        # Class methods
        def on_defs(node)
          method_name = "self.#{node.children[1]}"
          file = node.loc.expression.source_buffer.name
          line_num = node.loc.line

          # Set current method
          self.current_method = method_name

          debug "Class method #{current_class}.#{node.children[1]} in #{file}:#{line_num}"

          tree[current_class].add_method(method_name, file, line_num)

          # Traverse the AST (first two children are method name and arguments)
          node.children[2..].each { |c| process(c) }

          # Reset current method
          self.current_method = nil
        end

        # Method bodies
        def on_begin(node)
          node.children.each { |c| process(c) }
        end

        # Method calls
        def on_send(node)
          receiver, callee = method_from(node)

          constant_name = constant_name_from(receiver)

          # TODO: handle method calls on variables
          return if constant_name.blank?

          debug "Ignoring constant #{constant_name} in #{node.loc.expression.source_buffer.name}:#{node.loc.line}" and return if constant_name.in? IGNORE_CONSTANTS

          debug "Reference to #{constant_name}##{callee} from #{current_class}##{current_method} in #{node.loc.expression.source_buffer.name}:#{node.loc.line}"

          warn "No sender for method call #{constant_name}##{callee}" and return if current_class == MAIN

          tree[current_class].methods[current_method].references << Syntax::Reference.new(tree[constant_name], callee)
        end

        private

        def method_from(node)
          receiver = node.children[0]
          callee = node.children[1].to_s

          debug "Ignoring method call #{callee} in #{node.loc.expression.source_buffer.name}:#{node.loc.line}" and return if callee.in? IGNORE_METHODS

          warn "No receiver for method call #{callee} in #{node.loc.expression.source_buffer.name}:#{node.loc.line}" if receiver.nil?

          # If the receiver is a send, descend to the child node
          # We are only interested in the first callee
          return method_from(receiver) if receiver&.type == :send

          [receiver, callee]
        end

        def constant_name_from(node)
          # If current node is a send, descend to the child node
          return constant_name_from(node.children[0]) if node&.type == :send

          # If current node is not a constant, return current namespace
          # FIXME: fully qualify the constant
          return "" unless node&.type == :const

          # Current constant name
          name = node.children[1].to_s

          # Process the child node to build the namespace prefix
          prefix = constant_name_from(node.children[0])

          # Combine the prefix and the current name with a scope resolution operator (::)
          # If there's no prefix (i.e., we're at the top level), don't prepend ::
          prefix.empty? ? name : "#{prefix}::#{name}"
        end
      end
    end
  end
end
