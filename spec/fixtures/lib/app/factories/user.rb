# frozen_string_literal: true

module App
  module Factories
    class User
      def self.create(name, email)
        ::App::User.new(name, email)
      end

      def self.create_admin(name, email)
        ::App::User.new(name, email, admin: true)
      end
    end
  end
end
