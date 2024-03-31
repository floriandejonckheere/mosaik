# frozen_string_literal: true

module MOSAIK
  module Commands
    ##
    # Show the current application version
    #
    class Version < Command
      self.description = "Show the current application version"

      def call
        info "MOSAIK #{MOSAIK::VERSION}"
      end
    end
  end
end
