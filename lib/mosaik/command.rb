# frozen_string_literal: true

module MOSAIK
  class Command
    ##
    # Base class for commands
    #
    include Arguments

    def prepare; end

    def start; end
  end
end
