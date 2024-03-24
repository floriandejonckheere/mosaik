# frozen_string_literal: true

module MOSAIK
  class Registry
    attr_reader :constants, :hierarchy

    def initialize
      @constants = Hash.new { |h, k| h[k] = Constant.new(k) }
      @hierarchy = Hierarchy.new
    end

    def [](constant_path)
      # Register constant in hierarchy
      hierarchy[constant_path]

      # Register constant in registry
      @constants[constant_path]
    end
  end
end
