# frozen_string_literal: true

FactoryBot.define do
  factory :constant, class: MOSAIK::Constant do
    initialize_with { new(name) }

    name { "MOSAIK::Constant" }
  end

  factory :method, class: MOSAIK::Method do
    initialize_with { new(constant, name, file, line) }

    constant
    name { "initialize" }
    file { "lib/mosaik/constant.rb" }
    line { 6 }
  end
end
