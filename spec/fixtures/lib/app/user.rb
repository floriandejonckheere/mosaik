# frozen_string_literal: true

module App
  class User
    attr_reader :name, :email, :admin

    def initialize(name, email, admin: false)
      @name = name
      @email = email
      @admin = admin
    end

    alias admin? admin

    def to_s
      "#{name} <#{email}>"
    end
  end
end
