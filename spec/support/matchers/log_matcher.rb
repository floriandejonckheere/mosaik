# frozen_string_literal: true

RSpec::Matchers.define :log do |expected|
  match do |actual|
    logger = double

    # Mock MOSAIK.logger
    allow(MOSAIK)
      .to receive(:logger)
      .and_return logger

    # Store logs with level 'info'
    allow(logger)
      .to receive(:info) { |s| (@messages ||= []) << s.strip.uncolorize }
      .and_return nil

    # Discard logs with other levels
    [:error, :warn, :debug].each do |level|
      allow(logger)
        .to receive(level)
        .and_return nil
    end

    actual.call

    expect(@messages)
      .to(be_any { |m| m =~ (expected.is_a?(Regexp) ? expected : /#{Regexp.escape expected}/i) })
  end

  failure_message do |_actual|
    messages = @messages
      &.map
      &.with_index { |m, i| "\n#{(i + 1).to_s.rjust(5)}) #{m.uncolorize}" }
      &.join || "nothing"

    "expected block to log '#{expected}', but received: #{messages}"
  end

  supports_block_expectations
end
