# frozen_string_literal: true

module MOSAIK
  class CLI
    class Version < Base
      def validate; end

      def execute
        MOSAIK.configuration.logger.info "MOSAIK #{MOSAIK::VERSION}"
      end
    end
  end
end
