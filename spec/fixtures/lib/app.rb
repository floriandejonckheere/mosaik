# frozen_string_literal: true

module App
  def logger
    @logger ||= Logger.new($stdout)
  end
end
