# frozen_string_literal: true

FactoryBot.define do
  factory :command, class: "MOSAIK::Command" do
    initialize_with { new(options, *arguments) }

    transient do
      options { {} }
      arguments { [] }
    end
  end

  factory :extract_command, parent: :command, class: "MOSAIK::Commands::Extract"

  factory :identify_command, parent: :command, class: "MOSAIK::Commands::Identify"

  factory :evaluate_command, parent: :command, class: "MOSAIK::Commands::Evaluate"

  factory :init_command, parent: :command, class: "MOSAIK::Commands::Init"

  factory :version_command, parent: :command, class: "MOSAIK::Commands::Version"
end
