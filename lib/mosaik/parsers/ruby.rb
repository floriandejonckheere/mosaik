# frozen_string_literal: true

module MOSAIK
  module Parsers
    class Ruby
      def parse(file)
        ast = Parser::Ruby33
          .parse_file(file)

        processor
          .process(ast)

        puts processor
          .class_list
      end

      private

      def processor
        @processor ||= Processors::Ruby.new
      end
    end
  end
end
