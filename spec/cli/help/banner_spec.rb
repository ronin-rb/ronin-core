require 'spec_helper'
require 'ronin/core/cli/help/banner'

require 'command_kit/commands'
require 'stringio'

describe Ronin::Core::CLI::Help::Banner do
  module TestHelpBanner
    class TestCommand
      include CommandKit::Commands
      include Ronin::Core::CLI::Help::Banner

      command_name 'test'
    end
  end

  let(:test_command) { TestHelpBanner::TestCommand }
  subject { test_command.new }

  describe "#help" do
    let(:stdout) { StringIO.new }

    subject { test_command.new(stdout: stdout) }

    context "when stdout is a TTY" do
      before { allow(stdout).to receive(:tty?).and_return(true) }

      it "must print the Ronin ASCII art banner and the regular --help output" do
        subject.help

        expect(stdout.string).to start_with(
          [
            Ronin::Core::CLI::Banner::BANNER,
            "Usage: #{test_command.command_name} [options] [COMMAND [ARGS...]]",
            ''
          ].join($/)
        )
      end
    end

    context "when stdout is not a TTY" do
      it "must not print the Ronin ASCII art banner" do
        subject.help

        expect(stdout.string).to start_with(
          "Usage: #{test_command.command_name} [options] [COMMAND [ARGS...]]#{$/}"
        )
      end
    end
  end
end
