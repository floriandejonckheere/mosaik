# frozen_string_literal: true

RSpec.describe MOSAIK::CLI do
  subject(:cli) { described_class.new }

  it { is_expected.to respond_to :version }
end
