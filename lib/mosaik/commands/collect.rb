# frozen_string_literal: true

module MOSAIK
  module Commands
    class Collect < Command
      self.description = "Collect data"

      def start
        Collection::Static
          .new
          .call
      end
    end
  end
end
