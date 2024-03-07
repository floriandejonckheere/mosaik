# frozen_string_literal: true

module MOSAIK
  class CLI
    class Collect < Base
      def validate; end

      def execute
        MOSAIK.configuration.logger.info "Starting data collection..."
      end
    end
  end
end
