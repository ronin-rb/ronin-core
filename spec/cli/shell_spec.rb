require 'spec_helper'
require 'ronin/core/cli/shell'

describe Ronin::Core::CLI::Shell do
  describe ".shell_name" do
    subject { shell_class }

    context "and when shell_name is not set in the shell class" do
      module TestShell
        class ShellWithNoShellName < Ronin::Core::CLI::Shell
        end
      end

      let(:shell_class) { TestShell::ShellWithNoShellName }

      it "must default to nil" do
        expect(subject.shell_name).to be(nil)
      end
    end

    context "and when shell_name is set in the shell class" do
      module TestShell
        class ShellWithShellName < Ronin::Core::CLI::Shell
          shell_name 'test'
        end
      end

      let(:shell_class) { TestShell::ShellWithShellName }

      it "must return the set shell_name" do
        expect(subject.shell_name).to eq("test")
      end
    end

    context "but when the shell_name was set in the superclass" do
      module TestShell
        class ShellThatInheritsItsShellName < ShellWithShellName
        end
      end

      let(:shell_class) do
        TestShell::ShellThatInheritsItsShellName
      end

      it "must return the shell_name set in the superclass" do
        expect(subject.shell_name).to eq("test")
      end

      context "but the shell_name is overridden in the sub-class" do
        module TestShell
          class ShellThatOverridesItsInheritedShellName < ShellWithShellName
            shell_name "test2"
          end
        end

        let(:shell_class) do
          TestShell::ShellThatOverridesItsInheritedShellName
        end

        it "must return the shell_name set in the superclass" do
          expect(subject.shell_name).to eq("test2")
        end
      end
    end
  end

  module TestShell
    class TestShell < Ronin::Core::CLI::Shell
      shell_name 'test'
    end
  end

  let(:shell_class) { TestShell::TestShell }
  subject { shell_class.new }

  describe "#shell_name" do
    it "must return the shell class'es .shell_name" do
      expect(subject.shell_name).to eq(shell_class.shell_name)
    end
  end

  describe "#prompt" do
    let(:stdout) { StringIO.new }

    subject { shell_class.new(stdout: stdout) }

    context "when stdout is a TTY" do
      before do
        allow(subject.stdout).to receive(:tty?).and_return(true)
      end

      let(:red)             { CommandKit::Colors::ANSI::RED }
      let(:bright_red)      { CommandKit::Colors::ANSI::BRIGHT_RED }
      let(:bold)            { CommandKit::Colors::ANSI::BOLD }
      let(:reset_intensity) { CommandKit::Colors::ANSI::RESET_INTENSITY }
      let(:reset_color)     { CommandKit::Colors::ANSI::RESET_COLOR     }

      it "must return an ANSI colored prompt" do
        expect(subject.prompt).to eq(
          "#{red}#{subject.shell_name}#{reset_color}#{bold}#{bright_red}>#{reset_color}#{reset_intensity}"
        )
      end
    end

    context "when stdout is not a TTY" do
      it "must return a plain-text prompt" do
        expect(subject.prompt).to eq("#{subject.shell_name}>")
      end
    end
  end
end
