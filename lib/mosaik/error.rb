# frozen_string_literal: true

module MOSAIK
  # Base class
  class Error < StandardError; end

  # Raised when usage is printed
  class ExitError < Error; end

  # Raised when CLI arguments are invalid
  class UsageError < Error; end

  # Raised when options are invalid
  class OptionError < Error; end

  # Raised when configuration is invalid
  class ConfigurationError < Error; end

  # Raised when file type is unknown
  class UnknownFileType < Error; end
end
