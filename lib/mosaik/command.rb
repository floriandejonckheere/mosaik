# frozen_string_literal: true

module MOSAIK
  ##
  # Base class for commands
  #
  class Command
    include Arguments

    defaults hide_uncoupled: false,
             hide_labels: false

    argument("--hide-uncoupled", "Hide uncoupled vertices in the graph (default: #{defaults[:hide_uncoupled]})") { |arg| !arg.nil? }
    argument("--hide-labels", "Hide labels in the graph (default: #{defaults[:hide_labels]})") { |arg| !arg.nil? }

    def validate; end

    def call; end
  end
end
