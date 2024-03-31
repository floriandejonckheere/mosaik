# frozen_string_literal: true

FactoryBot.define do
  factory :constant, class: MOSAIK::Syntax::Constant do
    initialize_with { new(name) }

    name { "MOSAIK::Syntax::Constant" }
  end

  factory :method, class: MOSAIK::Syntax::Method do
    initialize_with { new(constant, name, file, line) }

    constant
    name { "initialize" }
    file { "lib/mosaik/constant.rb" }
    line { 6 }
  end

  factory :reference, class: MOSAIK::Syntax::Reference do
    initialize_with { new(constant, method) }

    constant
    add_attribute :method
  end

  factory :tree, class: MOSAIK::Syntax::Tree
end
