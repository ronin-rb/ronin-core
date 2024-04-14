require 'spec_helper'
require 'ronin/core/cli/logging'
require 'ronin/core/cli/command'
require 'stringio'

describe Ronin::Core::CLI::Logging do
  module TestLogging
    class TestCommand < Ronin::Core::CLI::Command

      include Ronin::Core::CLI::Logging

    end
  end

  let(:command_class) { TestLogging::TestCommand }
  let(:stdout) { StringIO.new }
  let(:stderr) { StringIO.new }
  subject { command_class.new(stdout: stdout, stderr: stderr) }

  let(:message) { "foo bar baz" }

  let(:bright_green)  { CommandKit::Colors::ANSI::BRIGHT_GREEN  }
  let(:bright_yellow) { CommandKit::Colors::ANSI::BRIGHT_YELLOW }
  let(:bright_red)    { CommandKit::Colors::ANSI::BRIGHT_RED    }
  let(:white)  { CommandKit::Colors::ANSI::WHITE  }
  let(:bold)   { CommandKit::Colors::ANSI::BOLD   }
  let(:reset_intensity) { CommandKit::Colors::ANSI::RESET_INTENSITY }
  let(:reset_color)     { CommandKit::Colors::ANSI::RESET_COLOR     }

  describe "#log_info" do
    context "when stdout is a TTY" do
      before { allow(stdout).to receive(:tty?).and_return(true) }

      it "must print '>>> message' in bright-green and bold-white to stdout" do
        subject.log_info(message)

        expect(stdout.string).to eq(
          "#{bold}#{bright_green}>>>#{reset_color}#{reset_intensity} #{bold}#{white}#{message}#{reset_color}#{reset_intensity}#{$/}"
        )
      end
    end

    context "when stdout is not a TTY" do
      it "must print '>>> message' to stdout" do
        subject.log_info(message)

        expect(stdout.string).to eq(">>> #{message}#{$/}")
      end
    end
  end

  describe "#log_warn" do
    context "when stdout is a TTY" do
      before { allow(stdout).to receive(:tty?).and_return(true) }

      it "must print '/!\\ message' in bright-yellow and bold-white to stdout" do
        subject.log_warn(message)

        expect(stdout.string).to eq(
          "#{bold}#{bright_red}/!\\#{reset_color}#{reset_intensity} #{bold}#{bright_yellow}#{message}#{reset_color}#{reset_intensity}#{$/}"
        )
      end
    end

    context "when stdout is not a TTY" do
      it "must print '/!\\ message' to stdout" do
        subject.log_warn(message)

        expect(stdout.string).to eq("/!\\ #{message}#{$/}")
      end
    end
  end

  describe "#log_error" do
    context "when stderr is a TTY" do
      before { allow(stderr).to receive(:tty?).and_return(true) }

      it "must print '!!! message' in bold-red and bold-white to stderr" do
        subject.log_error(message)

        expect(stderr.string).to eq(
          "#{bold}#{bright_red}!!!#{reset_color}#{reset_intensity} #{bold}#{white}#{message}#{reset_color}#{reset_intensity}#{$/}"
        )
      end
    end

    context "when stdout is not a TTY" do
      it "must print '!!! message' to stderr" do
        subject.log_error(message)

        expect(stderr.string).to eq("!!! #{message}#{$/}")
      end
    end
  end
end
