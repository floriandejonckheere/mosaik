# frozen_string_literal: true

RSpec::Matchers.define :log do |expected|
  match do |actual|
    logger = double

    # Mock MOSAIK.logger
    allow(MOSAIK)
      .to receive(:logger)
      .and_return logger

    # Store logged messages by log level
    [:debug, :info, :warn, :error, :fatal].each do |level|
      allow(logger)
        .to receive(level) { |s| ((@messages ||= {})[level] ||= []) << s.strip.uncolorize }
        .and_return nil
    end

    actual.call

    expect(@messages.values.flatten)
      .to(be_any { |m| m =~ (expected.is_a?(Regexp) ? expected : /#{Regexp.escape expected}/i) })
  end

  failure_message do |_actual|
    messages = @messages
      &.values
      &.flatten
      &.map
      &.with_index { |m, i| "\n#{(i + 1).to_s.rjust(5)}) #{m.uncolorize}" }
      &.join || "nothing"

    "expected block to log '#{expected}', but received: #{messages}"
  end

  supports_block_expectations
end
