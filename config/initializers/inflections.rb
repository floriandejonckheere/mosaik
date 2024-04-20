# frozen_string_literal: true

MOSAIK.loader.inflector.inflect(
  "abc_size" => "ABCSize",
  "cli" => "CLI",
  "mosaik" => "MOSAIK",
)

ActiveSupport::Inflector.inflections do |inflect|
  inflect.acronym "ABC"
  inflect.acronym "CLI"
  inflect.acronym "MOSAIK"
end
