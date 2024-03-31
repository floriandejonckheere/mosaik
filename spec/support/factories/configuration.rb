# frozen_string_literal: true

FactoryBot.define do
  factory :configuration, class: MOSAIK::Configuration do
    initialize_with { new(load_paths:, includes:, excludes:, overrides:) }

    load_paths { ["lib"] }
    includes { ["**/*.{rb,rake,erb}"] }
    excludes { ["{bin,node_modules,script,tmp,vendor}/**/*"] }
    overrides { { "foobar" => "FooBar" } }
  end
end
