# frozen_string_literal: true

module MOSAIK
  class Method
    attr_reader :name, :file, :line, :references

    def initialize(name, file, line)
      @name = name
      @file = file
      @line = line

      @references = []
    end
  end
end
