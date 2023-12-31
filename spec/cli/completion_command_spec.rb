require 'spec_helper'
require 'ronin/core/cli/completion_command'

describe Ronin::Core::CLI::CompletionCommand do
  module TestCompletionCommand
    class CommandWithoutCompletionFile < Ronin::Core::CLI::CompletionCommand
    end

    class CommandWithCompletionFile < Ronin::Core::CLI::CompletionCommand

      completion_file 'path/to/completion/file'

    end
  end

  describe ".completion_file" do
    subject { command_class }

    context "when no arguments are given" do
      context "and the completion_file has been previously set in the class" do
        let(:command_class) do
          TestCompletionCommand::CommandWithCompletionFile
        end

        it "must return the previously set completion_file" do
          expect(subject.completion_file).to eq('path/to/completion/file')
        end
      end

      context "when no completion_file has been set in the class" do
        let(:command_class) do
          TestCompletionCommand::CommandWithoutCompletionFile
        end

        it do
          expect {
            subject.completion_file
          }.to raise_error(NotImplementedError,"#{command_class} did not set completion_file")
        end
      end
    end
  end

  describe ".command_name" do
    subject { described_class }

    it "must be set to 'completion'" do
      expect(subject.command_name).to eq('completion')
    end
  end

  describe ".bug_report_url" do
    subject { described_class }

    it "must be set to 'https://github.com/ronin-rb/ronin-core/issues/new'" do
      expect(subject.bug_report_url).to eq('https://github.com/ronin-rb/ronin-core/issues/new')
    end
  end

  let(:command_class) { TestCompletionCommand::CommandWithCompletionFile }

  subject { command_class.new }

  describe "#initialize" do
    it "must default #mode to :print" do
      expect(subject.mode).to be(:print)
    end
  end

  describe "options" do
    context "when the --print option is given" do
      before { subject.option_parser.parse(%w[--install --print]) }

      it "must set #mode to :print" do
        expect(subject.mode).to be(:print)
      end
    end

    context "when the --install option is given" do
      before { subject.option_parser.parse(%w[--install]) }

      it "must set #mode to :install" do
        expect(subject.mode).to be(:install)
      end
    end

    context "when the --uninstall option is given" do
      before { subject.option_parser.parse(%w[--uninstall]) }

      it "must set #mode to :uninstall" do
        expect(subject.mode).to be(:uninstall)
      end
    end
  end

  describe "#completion_file" do
    context "and the completion_file has been previously set in the class" do
      let(:command_class) do
        TestCompletionCommand::CommandWithCompletionFile
      end

      it "must return the previously set completion_file" do
        expect(subject.completion_file).to eq('path/to/completion/file')
      end
    end

    context "when no completion_file has been set in the class" do
      let(:command_class) do
        TestCompletionCommand::CommandWithoutCompletionFile
      end

      it do
        expect {
          subject.completion_file
        }.to raise_error(NotImplementedError,"#{command_class} did not set completion_file")
      end
    end
  end

  describe "#run" do
    context "when no options are given" do
      it "must call #print_completion_file with #completion_file" do
        expect(subject).to receive(:print_completion_file).with(subject.completion_file)

        subject.run
      end
    end

    context "when the --print option is given" do
      before { subject.option_parser.parse(%w[--print]) }

      it "must call #print_completion_file with #completion_file" do
        expect(subject).to receive(:print_completion_file).with(subject.completion_file)

        subject.run
      end
    end

    context "when the --install option is given" do
      before { subject.option_parser.parse(%w[--install]) }

      it "must call #install_completion_file with #completion_file" do
        expect(subject).to receive(:install_completion_file).with(subject.completion_file)

        subject.run
      end
    end

    context "when the --uninstall option is given" do
      before { subject.option_parser.parse(%w[--uninstall]) }

      it "must call #uninstall_completion_file with the basename of the #completion_file" do
        expect(subject).to receive(:uninstall_completion_file_for).with(
          File.basename(subject.completion_file)
        )

        subject.run
      end
    end

    context "when #mode is neither :print, :install, or :uninstall" do
      let(:mode) { :foo }

      before do
        subject.instance_variable_set(:@mode,mode)
      end

      it do
        expect {
          subject.run
        }.to raise_error(NotImplementedError,"mode not implemented: #{mode.inspect}")
      end
    end
  end
end
