# frozen_string_literal: true

module MOSAIK
  module Commands
    class Version < Command
      self.description = "Show the current application version"

      def start
        info "MOSAIK #{MOSAIK::VERSION}"
      end
    end
  end
end
