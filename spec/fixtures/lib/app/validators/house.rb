# frozen_string_literal: true

module App
  module Validators
    class House
      def self.valid?(house)
        house.address.include? "Street"
      end
    end
  end
end
