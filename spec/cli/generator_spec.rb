require 'spec_helper'
require 'ronin/core/cli/generator'

describe Ronin::Core::CLI::Generator do
  module TestGenerator
    class WithoutTemplateDir < Ronin::Core::CLI::Command
      include Ronin::Core::CLI::Generator
    end

    class WithTemplateDir < Ronin::Core::CLI::Command

      include Ronin::Core::CLI::Generator

      template_dir File.join(__dir__,'fixtures','template')

    end

    class InheritedTemplateDir < WithTemplateDir
    end
  end

  let(:command_class) { TestGenerator::WithTemplateDir}
  subject { command_class.new }

  describe ".template_dir" do
    context "when called without arguments" do
      context "and the .template_dir has been perviously defined" do
        let(:command_class) { TestGenerator::WithTemplateDir }

        it "must set the previously set template_dir" do
          expect(command_class.template_dir).to eq(File.join(__dir__,'fixtures','template'))
        end
      end

      context "but the .template_dir has been defined in the superclass" do
        let(:command_superclass) { TestGenerator::WithTemplateDir }
        let(:command_class) { TestGenerator::InheritedTemplateDir }

        it "must return the template_dir set in the superclass" do
          expect(command_class.template_dir).to eq(command_superclass.template_dir)
        end
      end

      context "but the template_dir has not been defined" do
        let(:command_class) { TestGenerator::WithoutTemplateDir }

        it "must return nil" do
          expect(command_class.template_dir).to be(nil)
        end
      end
    end

    context "when called with a String" do
      let(:command_class) { TestGenerator::WithTemplateDir }

      it "must set the template_dir" do
        expect(command_class.template_dir).to eq(File.join(__dir__,'fixtures','template'))
      end
    end
  end

  describe "#initialize" do
    context "when the template_dir has been previously defined" do
      it "must set #template_dir to the class'es .template_dir" do
        expect(subject.template_dir).to eq(command_class.template_dir)
      end
    end

    context "when the template_dir has not been previously defined" do
      let(:command_class) { TestGenerator::WithoutTemplateDir }

      it do
        expect {
          command_class.new
        }.to raise_error(NotImplementedError,"#{command_class} did not define template_dir")
      end
    end
  end

  describe "#print_action" do
    let(:stdout) { StringIO.new }

    subject { command_class.new(stdout: stdout) }

    context "when two arguments are given" do
      let(:command) { 'touch' }
      let(:dest)    { 'path/to/file' }

      context "and STDOUT is a TTY" do
        let(:ansi) { CommandKit::Colors::ANSI }

        before do
          allow(stdout).to receive(:tty?).and_return(true)
        end

        it "must output the command and dest highlighted in bold green" do
          expect(stdout).to receive(:puts).with("\t#{ansi.bold(ansi.green(command))}\t#{ansi.green(dest)}")

          subject.print_action(command,dest)
        end
      end

      context "but STDOUT is not a TTY" do
        it "must output the command and dest path separated by tabs" do
          expect(stdout).to receive(:puts).with("\t#{command}\t#{dest}")

          subject.print_action(command,dest)
        end
      end
    end

    context "when three arguments are given" do
      let(:command) { 'cp -r' }
      let(:source)  { 'dir' }
      let(:dest)    { 'path/to/file' }

      context "and STDOUT is a TTY" do
        let(:ansi) { CommandKit::Colors::ANSI }

        before do
          allow(stdout).to receive(:tty?).and_return(true)
        end

        it "must output the command, source, and dest highlighted in bold green" do
          expect(stdout).to receive(:puts).with("\t#{ansi.bold(ansi.green(command))}\t#{ansi.green(source)}\t#{ansi.green(dest)}")

          subject.print_action(command,source,dest)
        end
      end

      context "but STDOUT is not a TTY" do
        it "must output the command, source, and dest path separated by tabs" do
          expect(stdout).to receive(:puts).with("\t#{command}\t#{source}\t#{dest}")

          subject.print_action(command,source,dest)
        end
      end
    end
  end

  describe "#mkdir" do
    let(:dest) { 'path/to/new_dir' }

    it "must call #print_action and call FileUtils.mkdir_p" do
      expect(subject).to receive(:print_action).with('mkdir',dest)
      expect(FileUtils).to receive(:mkdir_p).with(dest)

      subject.mkdir(dest)
    end
  end

  describe "#touch" do
    let(:dest) { 'path/to/new_file' }

    it "must call #print_action and call FileUtils.touch" do
      expect(subject).to receive(:print_action).with('touch',dest)
      expect(FileUtils).to receive(:touch).with(dest)

      subject.touch(dest)
    end
  end

  describe "#cp" do
    let(:source) { 'file.txt' }
    let(:dest)   { 'path/to/root' }

    it "must call #print_action and call FileUtils.cp" do
      expect(subject).to receive(:print_action).with('cp',source,dest)
      expect(FileUtils).to receive(:cp).with(
        File.join(subject.template_dir,source), dest
      )

      subject.cp(source,dest)
    end
  end

  describe "#cp_r" do
    let(:source) { 'dir' }
    let(:dest)   { 'path/to/root' }

    it "must call #print_action and call FileUtils.cp_r" do
      expect(subject).to receive(:print_action).with('cp -r',source,dest)
      expect(FileUtils).to receive(:cp_r).with(
        File.join(subject.template_dir,source), dest
      )

      subject.cp_r(source,dest)
    end
  end

  describe "#erb" do
    let(:source) { 'file.erb' }
    let(:dest)   { 'path/to/new_file.txt' }

    it "must call #print_action, render the ERB, and call File.write" do
      expect(subject).to receive(:print_action).with('erb',source,dest)
      expect(File).to receive(:write).with(
        dest, "1 + 1 = 2"
      )

      subject.erb(source,dest)
    end

    context "when no destination path is given" do
      it "must not call #print_action, but return the rendered result" do
        expect(subject).to_not receive(:print_action).with('erb',source,dest)
        expect(File).to_not receive(:write).with(
          dest, "1 + 1 = 2"
        )

        expect(subject.erb(source)).to eq("1 + 1 = 2")
      end
    end
  end

  describe "#sh" do
    let(:status) { double(:exit_status) }

    let(:command) { 'cmd' }
    let(:args)    { %w[-a -b foo] }

    it "must call #print_action and run the command" do
      expect(subject).to receive(:print_action).with(
        'run', [command,*args].join(' ')
      )

      expect(subject).to receive(:system).with(command,*args).and_return(status)

      expect(subject.sh(command,*args)).to be(status)
    end
  end
end
