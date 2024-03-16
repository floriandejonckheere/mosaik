# frozen_string_literal: true

module MOSAIK
  # Base class
  class Error < StandardError; end

  # Raised when CLI arguments are invalid
  class UsageError < Error; end
end
