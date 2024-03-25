# frozen_string_literal: true

module MOSAIK
  module Commands
    class Collect < Command
      self.description = "Collect data"

      defaults type: "static",
               output: "mosaik.dot",
               force: false

      argument "-t", "--type TYPE", "Type of collection (default: static, available: static, dynamic, contributor)"
      argument "-o", "--output OUTPUT", "Output file (default: mosaik.dot)"
      argument "-f", "--force", "Overwrite existing file"

      def prepare
        raise OptionError, "unknown collection type: #{options[:type]}" unless ["static"].include?(options[:type])
        raise OptionError, "file already exists: #{options[:output]}, use --force to overwrite" if File.exist?(options[:output]) && !options[:force]
      end

      def start
        case options[:type]
        when "static"
          Collectors::Static
            .new(options)
            .call
        when "dynamic"
          # TODO
        when "contributor"
          # TODO
        end
      end
    end
  end
end
