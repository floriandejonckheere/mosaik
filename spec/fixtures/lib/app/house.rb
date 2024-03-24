# frozen_string_literal: true

module App
  class House
    def initialize(address)
      @address = address
    end

    def address
      @address
    end

    def valid?
      Validators::House.valid?(self)
    end
  end
end
