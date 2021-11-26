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

  let(:ansi) { CommandKit::Colors::ANSI }

  describe "#log_info" do
    context "when stdout is a TTY" do
      before { allow(stdout).to receive(:tty?).and_return(true) }

      it "must print '>>> message' in bold-green and bold-white to stdout" do
        subject.log_info(message)

        expect(stdout.string).to eq(
          "#{ansi.bold(ansi.green('>>>'))} #{ansi.bold(ansi.white(message))}#{$/}"
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

      it "must print '*** message' in bold-yellow and bold-white to stdout" do
        subject.log_warn(message)

        expect(stdout.string).to eq(
          "#{ansi.bold(ansi.yellow('***'))} #{ansi.bold(ansi.white(message))}#{$/}"
        )
      end
    end

    context "when stdout is not a TTY" do
      it "must print '*** message' to stdout" do
        subject.log_warn(message)

        expect(stdout.string).to eq("*** #{message}#{$/}")
      end
    end
  end

  describe "#log_error" do
    context "when stderr is a TTY" do
      before { allow(stderr).to receive(:tty?).and_return(true) }

      it "must print '!!! message' in bold-red and bold-white to stderr" do
        subject.log_error(message)

        expect(stderr.string).to eq(
          "#{ansi.bold(ansi.red('!!!'))} #{ansi.bold(ansi.white(message))}#{$/}"
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
