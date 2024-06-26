# frozen_string_literal: true

module MOSAIK
  module Commands
    ##
    # Initialize a new configuration file
    #
    class Init < Command
      self.description = "Initialize configuration"

      def call
        configuration_file = File.join(options[:directory], "mosaik.yml")

        raise ConfigurationError, "Configuration file already exists at #{configuration_file}" if File.exist?(configuration_file)

        FileUtils.cp(MOSAIK.root.join("config/mosaik.yml"), configuration_file)

        info "Configuration written to #{configuration_file}"
      end
    end
  end
end
