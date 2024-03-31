# frozen_string_literal: true

FactoryBot.define do
  factory :configuration, class: MOSAIK::Configuration do
    initialize_with { new(directory:, load_paths:, includes:, excludes:, overrides:) }

    directory { MOSAIK.root.join("spec", "fixtures") }
    load_paths { ["lib"] }
    includes { ["**/*.{rb,rake,erb}"] }
    excludes { ["{bin,node_modules,script,tmp,vendor}/**/*"] }
    overrides { { "foobar" => "FooBar" } }
  end
end
