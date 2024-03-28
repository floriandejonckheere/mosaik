# frozen_string_literal: true

module MOSAIK
  module Commands
    class Init < Command
      self.description = "Initialize configuration"

      def start
        configuration_file = File.join(MOSAIK.options.directory, "mosaik.yml")

        raise ConfigurationError, "Configuration file already exists at #{configuration_file}" if File.exist?(configuration_file)

        template = <<~YAML
          ---
          # Application load paths
          load_paths:
            - .

          # List of patterns for files to include
          include:
            - "**/*.{rb,rake,erb}"

          # List of patterns for files to exclude
          exclude:
            - "{bin,node_modules,script,tmp,vendor}/**/*"
        YAML

        File.write(configuration_file, template)

        info "Configuration written to #{configuration_file}"
      end
    end
  end
end
