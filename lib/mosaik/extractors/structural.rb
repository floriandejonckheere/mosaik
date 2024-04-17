# frozen_string_literal: true

module MOSAIK
  module Extractors
    ##
    # Structural coupling extractor
    #
    class Structural < Extractor
      def call
        return unless options[:type].include?("structural")

        # Instantiate a constant tree
        tree = Syntax::Tree.new

        # Parse files
        MOSAIK.configuration.files.each do |file|
          Parser
            .new
            .parse(file, tree)
        end

        # Count total constants and methods
        total = tree.to_h { |c| [c.name, c.methods.count] }
        info "Parsed #{total.count} classes and #{total.values.sum} methods"

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

        # Construct the graph
        tree.each { |constant| construct(constant) } # rubocop:disable Style/CombinableLoops
      end

      private

      def construct(constant)
        # Find or create the node for the constant
        caller = graph.find_or_add_vertex(constant.name)

        # Add method cardinality to the vertex
        caller.attributes[:methods] = constant.methods.count

        constant.methods.each_value do |method|
          method.references.each do |reference|
            # Find or create the the receiver node
            receiver = graph.find_or_add_vertex(reference.constant.name)

            debug "Edge from #{caller.id} to #{receiver.id}##{reference.method}"

            # Add an edge from the constant to the receiver
            graph.add_edge(caller.id, receiver.id, type: "structural", method: reference.method)
          end
        end
      end
    end
  end
end
