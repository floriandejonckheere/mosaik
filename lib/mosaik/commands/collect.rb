# frozen_string_literal: true

module MOSAIK
  module Commands
    class Collect < Command
      self.description = "Collect data"

      defaults output: "mosaik.dot"

      argument "-o", "--output OUTPUT", "Output directory"

      def start
        info options
        Collection::Static
          .new
          .call
      end
    end
  end
end
