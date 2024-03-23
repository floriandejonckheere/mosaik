# frozen_string_literal: true

FactoryBot.define do
  factory :command, class: "MOSAIK::Command" do
    initialize_with { new(nil, *args) }

    transient do
      args { [] }
    end
  end

  factory :collect_command, parent: :command, class: "MOSAIK::Commands::Collect"

  factory :init_command, parent: :command, class: "MOSAIK::Commands::Init"

  factory :version_command, parent: :command, class: "MOSAIK::Commands::Version"
end
