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

  describe ".prompt_sigil" do
    subject { shell_class }

    context "and when prompt_sigil is not set in the shell class" do
      module TestShell
        class ShellWithNoPromptSigil < Ronin::Core::CLI::Shell
        end
      end

      let(:shell_class) { TestShell::ShellWithNoPromptSigil }

      it "must default to '>'" do
        expect(subject.prompt_sigil).to eq('>')
      end
    end

    context "and when prompt_sigil is set in the shell class" do
      module TestShell
        class ShellWithPromptSigil < Ronin::Core::CLI::Shell
          prompt_sigil '$'
        end
      end

      let(:shell_class) { TestShell::ShellWithPromptSigil }

      it "must return the set prompt_sigil" do
        expect(subject.prompt_sigil).to eq("$")
      end
    end

    context "but when the prompt_sigil was set in the superclass" do
      module TestShell
        class ShellThatInheritsItsPromptSigil < ShellWithPromptSigil
        end
      end

      let(:shell_class) do
        TestShell::ShellThatInheritsItsPromptSigil
      end

      it "must return the prompt_sigil set in the superclass" do
        expect(subject.prompt_sigil).to eq("$")
      end

      context "but the prompt_sigil is overridden in the sub-class" do
        module TestShell
          class ShellThatOverridesItsInheritedPromptSigil < ShellWithPromptSigil
            prompt_sigil "#"
          end
        end

        let(:shell_class) do
          TestShell::ShellThatOverridesItsInheritedPromptSigil
        end

        it "must return the prompt_sigil set in the superclass" do
          expect(subject.prompt_sigil).to eq("#")
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

  describe "#initialize" do
    context "when no keyword arguments are given" do
      it "must default #shell_name to self.class.shell_name" do
        expect(subject.shell_name).to eq(shell_class.shell_name)
      end

      it "must default #prompt_sigil to self.class.prompt_sigil" do
        expect(subject.prompt_sigil).to eq(shell_class.prompt_sigil)
      end
    end

    context "when the shell_name: keyword argument is given" do
      let(:new_shell_name) { 'override' }

      subject { shell_class.new(shell_name: new_shell_name) }

      it "must override #shell_name" do
        expect(subject.shell_name).to eq(new_shell_name)
      end
    end

    context "when the prompt_sigil: keyword argument is given" do
      let(:new_prompt_sigil) { '$' }

      subject { shell_class.new(prompt_sigil: new_prompt_sigil) }

      it "must override #prompt_sigil" do
        expect(subject.prompt_sigil).to eq(new_prompt_sigil)
      end
    end
  end

  describe "#shell_name" do
    it "must return the shell class'es .shell_name" do
      expect(subject.shell_name).to eq(shell_class.shell_name)
    end
  end

  describe "#prompt_sigil" do
    it "must return the shell class'es .prompt_sigil" do
      expect(subject.prompt_sigil).to eq(shell_class.prompt_sigil)
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
