# frozen_string_literal: true

module MOSAIK
  module Parsers
    ##
    # Parser for Ruby code
    #
    class Ruby
      def parse(file, tree)
        debug "Parsing file: #{file}"

        # Parse Abstract Syntax Tree
        ast = Parser::Ruby33
          .parse_file(file)

        # Process AST to extract constants, methods and references
        Processors::Ruby
          .new(tree)
          .process(ast)
      end
    end
  end
end
