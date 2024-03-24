# frozen_string_literal: true

module App
  class User
    def initialize(name, email, admin: false)
      @name = name
      @email = email
      @admin = admin
    end

    def name
      @name
    end

    def email
      @email
    end

    def admin
      @admin
    end

    alias admin? admin

    def valid?
      Validators::User.valid?(self)
    end

    def to_s
      "#{name} <#{email}>"
    end
  end
end
