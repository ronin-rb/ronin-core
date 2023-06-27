require 'spec_helper'
require 'ronin/core/cli/banner'
require 'ronin/core/cli/command'

describe Ronin::Core::CLI::Banner do
  module TestBanner
    class TestCommand
      include Ronin::Core::CLI::Banner
    end
  end

  let(:test_command) { TestBanner::TestCommand }
  subject { test_command.new }

  describe "#print_banner" do
    it "must print the BANNER and the regular --help output" do
      expect {
        subject.print_banner
      }.to output("#{described_class::BANNER}#{$/}").to_stdout
    end
  end
end
