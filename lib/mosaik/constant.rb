# frozen_string_literal: true

module MOSAIK
  class Constant
    attr_reader :name, :methods

    def initialize(name)
      @name = name

      @methods = []
    end
  end
end
