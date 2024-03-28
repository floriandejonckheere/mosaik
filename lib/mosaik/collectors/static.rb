# frozen_string_literal: true

module MOSAIK
  module Collectors
    class Static < Collector
      PARSERS = {
        ".rb" => Parsers::Ruby,
      }.freeze

      def call
        # Instantiate a constant registry
        registry = Registry.new

        # Parse file with an appropriate parser
        MOSAIK.configuration.files.each do |file|
          PARSERS
            .fetch(File.extname(file))
            .new
            .parse(file, registry)
        rescue KeyError
          raise UnknownFileType, "No parser for file type: #{File.extname(file)}"
        end

        # Print the registry
        registry.each do |constant|
          debug constant

          constant.methods.each_value do |method|
            debug "  #{method}"

            method.references.each do |reference|
              debug "    #{reference}"
            end
          end

          # Print the hierarchy
          debug ("  " * constant.name.scan("::").count) + constant.name
        end

        registry.each { |constant| construct(constant) } # rubocop:disable Style/CombinableLoops

        # Write the graph to a file
        graph.output(dot: options[:output])

        info "Call graph written to #{options[:output]}"
      end

      private

      def construct(constant)
        # Get or create the node for the constant
        node = graph.get_node(constant.name) || graph.add_node(constant.name)

        # TODO: method-level granularity
        constant.methods.each_value do |method|
          method.references.each do |reference|
            # Get or create the the receiver node
            receiver = graph.get_node(reference.constant.name) || graph.add_node(reference.constant.name)

            debug "Edge from #{constant.name} to #{reference.constant.name}##{reference.method}"

            # Add an edge from the constant to the receiver
            graph.add_edge(node, receiver, label: reference.method)
          end
        end
      end
    end
  end
end
