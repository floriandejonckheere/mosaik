# frozen_string_literal: true

module MOSAIK
  module Parsers
    class Ruby
      def parse(file, registry)
        ast = Parser::Ruby33
          .parse_file(file)

        Processors::Ruby
          .new(file, registry)
          .process(ast)
      end
    end
  end
end