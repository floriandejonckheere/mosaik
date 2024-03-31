# frozen_string_literal: true

module MOSAIK
  class Configuration
    class Weights
      attr_reader :structural, :logical, :contributor

      def initialize(weights)
        @structural = weights["structural"] || 1
        @logical = weights["logical"] || 1
        @contributor = weights["contributor"] || 1
      end
    end
  end
end
