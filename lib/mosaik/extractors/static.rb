# frozen_string_literal: true

module MOSAIK
  module Extractors
    class Static < Extractor
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
      end

      private

      def construct(constant)
        # Find or create the node for the constant
        caller = graph.find_or_add_vertex(constant.name)

        # TODO: method-level granularity
        constant.methods.each_value do |method|
          method.references.each do |reference|
            # Find or create the the receiver node
            receiver = graph.find_or_add_vertex(reference.constant.name)

            debug "Edge from #{caller.value} to #{receiver.value}##{reference.method}"

            # Add an edge from the constant to the receiver
            graph.add_edge(caller.value, receiver.value, label: reference.method)
          end
        end
      end
    end
  end
end
