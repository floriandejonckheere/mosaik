# frozen_string_literal: true

module MOSAIK
  module Graph
    ##
    # Visualize the graph
    #
    class Visualizer
      attr_reader :options, :graph

      def initialize(options, graph)
        @options = options
        @graph = graph
      end

      def to_dot
        # Set of visited edges (to avoid duplicates in undirected graphs)
        visited = Set.new

        # List of vertices with incoming or outgoing edges
        coupled_vertices = graph
          .vertices
          .values
          .select { |v| v.edges.any? } + graph
            .vertices
            .values
            .map { |v| v.edges.keys }
            .flatten(2)
            .uniq
            .map { |id| graph.find_vertex(id) }

        [
          graph.directed ? "digraph {" : "graph {",
          (if graph.clusters.any?
             graph
               .clusters
               .values
               .filter_map do |cluster|
               next unless options[:show_uncoupled] || (cluster.vertices.any? { |vertex| vertex.edges.any? })

               [
                 "subgraph \"#{cluster.id}\" {",
                 "  cluster = true",
                 "  label = \"#{cluster.id}\"",
                 '  color = "gray"',
                 *cluster.vertices.map { |vertex| "  \"#{vertex.id}\"" },
                 "}",
               ]
             end.join("\n  ").prepend("  ")
           end),
          graph
            .vertices
            .values
            .map do |vertex|
            [
              ("\"#{vertex.id}\" [shape=circle, width=1, fixedsize=true, fontsize=12, style=filled, fillcolor=lightblue]" if options[:show_uncoupled] || vertex.in?(coupled_vertices)),
              *vertex
                .edges
                .flat_map do |key, edges|
                edges.map do |edge|
                  next if edge.in? visited

                  visited << edge

                  [
                    "\"#{vertex.id}\" ",
                    graph.directed? ? "->" : "--",
                    " \"#{key}\"",
                    options[:show_labels] && edge.attributes.any? ? " [label=\"#{edge.attributes.map { |ek, ev| "#{ek}: #{ev}" }.join(', ')}\"]" : nil,
                  ].compact.join
                end
              end,
            ].compact_blank.join("\n  ")
          end.compact_blank.join("\n  ").prepend("  "),
          "}\n",
        ].compact.join("\n")
      end

      def to_png(file)
        File.write("#{file}.gv", to_dot)
        system("#{options.fetch(:renderer, 'dot')} -x -Goverlap=scale -Tpng #{file}.gv -o #{file}.png#{' 2> /dev/null' unless options[:debug]}")
      end

      def to_svg(file)
        File.write("#{file}.gv", to_dot)
        system("#{options.fetch(:renderer, 'dot')} -x -Goverlap=scale -Tsvg #{file}.gv -o #{file}.svg#{' 2> /dev/null' unless options[:debug]}")
      end
    end
  end
end
