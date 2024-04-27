# frozen_string_literal: true

module MOSAIK
  ##
  # Time utilities
  #
  class Time
    def self.measure
      # Save start time
      start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      yield

      # Save end time
      end_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      # Return execution time (in seconds)
      end_time - start_time
    end
  end
end
