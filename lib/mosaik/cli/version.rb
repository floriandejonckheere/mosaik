# frozen_string_literal: true

module MOSAIK
  class CLI
    class Version < Base
      def validate; end

      def execute
        puts "MOSAIK #{MOSAIK::VERSION}"
      end
    end
  end
end
