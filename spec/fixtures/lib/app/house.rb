# frozen_string_literal: true

module App
  class House
    attr_reader :address

    def initialize(address)
      @address = address
    end
  end
end
