# frozen_string_literal: true

module MOSAIK
  class Hierarchy
    attr_reader :constants

    def initialize
      @constants = {}
    end

    def [](constant)
      # Split constant by :: and descend into hierarchy
      current = constants

      constant.split("::").each do |cst|
        current[cst] ||= {}

        current = current[cst]
      end

      current
    end
  end
end
