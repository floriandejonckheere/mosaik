# frozen_string_literal: true

module App
  module Validators
    class User
      def self.valid?(user)
        user.name.present? &&
          user.email.present? &&
          user.email.include?("@")
      end
    end
  end
end
