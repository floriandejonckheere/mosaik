# frozen_string_literal: true

module MOSAIK
  class Registry
    include Enumerable

    attr_reader :hierarchy

    def initialize
      @hierarchy = {}
    end

    def [](constant_path)
      # Split constant path by ::
      current_hierarchy = hierarchy

      constant_path.split("::").each do |constant_name|
        current_hierarchy[constant_name] ||= {}

        # Descend into hierarchy
        current_hierarchy = current_hierarchy[constant_name]
      end

      constants[constant_path]
    end

    def each(...)
      constants.values.each(...)
    end

    private

    def constants
      @constants ||= Hash.new { |h, k| h[k] = Constant.new(k) }
    end
  end
end
