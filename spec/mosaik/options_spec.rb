# frozen_string_literal: true

RSpec.describe MOSAIK::Options do
  subject(:options) { described_class.new }

  it { is_expected.to respond_to :directory, :directory?, :directory= }
  it { is_expected.to respond_to :verbose, :verbose?, :verbose= }
  it { is_expected.to respond_to :debug, :debug?, :debug= }

  describe "#[]" do
    it "gets the option value" do
      options.directory = "/foobar"

      expect(options[:directory]).to eq "/foobar"
    end
  end

  describe "#[]=" do
    it "sets the option value" do
      options[:directory] = "/foobar"

      expect(options.directory).to eq "/foobar"
    end
  end
end
