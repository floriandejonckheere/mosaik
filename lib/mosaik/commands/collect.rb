# frozen_string_literal: true

module MOSAIK
  module Commands
    class Collect < Command
      self.description = "Collect data"

      defaults output: "mosaik.dot",
               force: false

      argument "-o", "--output OUTPUT", "Output file (default: mosaik.dot)"
      argument "-f", "--force", "Overwrite existing file"

      def prepare
        raise OptionError, "file already exists: #{options[:output]}, use --force to overwrite" if File.exist?(options[:output]) && !options[:force]
      end

      def start
        Collection::Static
          .new
          .call
      end
    end
  end
end
