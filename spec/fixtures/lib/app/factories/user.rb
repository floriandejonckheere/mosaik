# frozen_string_literal: true

module App
  module Factories
    class User
      def self.create(name, email)
        Foo::App.logger.info "Creating a new user: #{name} (#{email})"

        user = ::App::User.new(name, email)

        raise ArgumentError, "Invalid user" unless user.valid?

        user
      end

      def self.create_admin(name, email)
        App.logger.info "Creating a new admin user: #{name} (#{email})"

        admin = ::App::User.new(name, email, admin: true)

        raise ArgumentError, "Invalid admin user" unless admin.valid?

        admin
      end
    end
  end
end
