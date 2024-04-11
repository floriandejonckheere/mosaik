# frozen_string_literal: true

module MOSAIK
  module Extractors
    ##
    # Structural coupling extractor
    #
    class Structural < Extractor
      PARSERS = {
        ".rb" => Parsers::Ruby,
      }.freeze

      def call
        return unless options[:structural].positive?

        # Instantiate a constant tree
        tree = Syntax::Tree.new

        # Parse file with an appropriate parser
        MOSAIK.configuration.files.each do |file|
          PARSERS
            .fetch(File.extname(file))
            .new
            .parse(file, tree)
        rescue KeyError
          raise UnknownFileType, "No parser for file type: #{File.extname(file)}"
        end

        # Print the constant tree
        tree.each do |constant|
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

        tree.each { |constant| construct(constant) } # rubocop:disable Style/CombinableLoops
      end

      private

      def construct(constant)
        # Find or create the node for the constant
        caller = graph.find_or_add_vertex(constant.name)

        constant.methods.each_value do |method|
          method.references.each do |reference|
            # Find or create the the receiver node
            receiver = graph.find_or_add_vertex(reference.constant.name)

            debug "Edge from #{caller.id} to #{receiver.id}##{reference.method}"

            # Add an edge from the constant to the receiver
            edge = graph.find_or_add_edge(caller.id, receiver.id)

            # Set or increment weight on edge
            edge.attributes[:weight] ||= 0
            edge.attributes[:weight] += options[:structural]
          end
        end
      end
    end
  end
end
