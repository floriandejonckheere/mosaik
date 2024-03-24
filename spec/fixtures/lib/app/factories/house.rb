# frozen_string_literal: true

module App
  module Factories
    class House
      def self.create(address)
        App.logger.info "Creating a new house at #{address}"

        house = ::App::House.new(address)

        raise ArgumentError, "Invalid address" unless house.valid?

        house
      end
    end
  end
end
