# frozen_string_literal: true

module MOSAIK
  module Commands
    class Collect < Command
      self.description = "Collect data"

      def start
        info "Starting data collection..."
      end
    end
  end
end
