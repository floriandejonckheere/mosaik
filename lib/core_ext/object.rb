# frozen_string_literal: true

module CoreExt
  module Object
    def logger
      MOSAIK.logger
    end

    delegate :debug, :info, :warn, :error, :fatal, to: :logger
  end
end

Object.include CoreExt::Object
