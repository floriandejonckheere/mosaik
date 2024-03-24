# frozen_string_literal: true

module App
  module Factories
    class House
      def self.create(address)
        ::App::House.new(address)
      end
    end
  end
end
