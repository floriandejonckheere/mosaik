# frozen_string_literal: true

module MOSAIK
  class Registry
    attr_reader :constants

    def initialize
      @constants = Hash.new { |h, k| h[k] = Constant.new(k) }
    end
  end
end
