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

      let(:shell_class) { TestShell::ShellThatInheritsItsShellName }

      it "must return the shell_name set in the superclass" do
        expect(subject.shell_name).to eq("test")
      end

      context "but the shell_name is overridden in the sub-class" do
        module TestShell
          class ShellThatOverridesItsInheritedShellName < ShellWithShellName
            shell_name "test2"
          end
        end

        let(:shell_class) { TestShell::ShellThatOverridesItsInheritedShellName }

        it "must return the shell_name set in the superclass" do
          expect(subject.shell_name).to eq("test2")
        end
      end
    end
  end

  describe ".commands" do
    subject { shell_class }

    context "when no commands have been defined in the shell class" do
      module TestShell
        class ShellWithNoCommands < Ronin::Core::CLI::Shell
          shell_name 'test'
        end
      end

      let(:shell_class) { TestShell::ShellWithNoCommands }

      it "must return a Hash only containing the help command" do
        expect(subject.commands.keys).to eq(%w[help])
        expect(subject.commands['help']).to be_kind_of(described_class::Command)
      end
    end

    context "when commands have been defined in the shell class" do
      module TestShell
        class ShellWithCommands < Ronin::Core::CLI::Shell
          shell_name 'test'

          command :foo, summary: 'Foo command'
          def foo
          end
        end
      end

      let(:shell_class) { TestShell::ShellWithCommands }

      it "must return the Hash of command names and Command classes" do
        expect(subject.commands['foo']).to be_kind_of(described_class::Command)
        expect(subject.commands['foo'].name).to eq(:foo)
        expect(subject.commands['foo'].summary).to eq('Foo command')
      end
    end

    context "but when the commands are defined in the superclass" do
      module TestShell
        class ShellWithInheritedCommands < ShellWithCommands
          shell_name 'test'
        end
      end

      let(:shell_superclass) { TestShell::ShellWithCommands          }
      let(:shell_class)      { TestShell::ShellWithInheritedCommands }

      it "must return the commands defined in the superclass" do
        expect(subject.commands['foo']).to be(shell_superclass.commands['foo'])
      end

      context "but additional commands are defined in the sub-class" do
        module TestShell
          class ShellWithInheritedCommandsAndItsOwnCommands < ShellWithCommands
            shell_name 'test'
            command :bar, summary: 'Bar command'
            def bar
            end
          end
        end

        let(:shell_class) { TestShell::ShellWithInheritedCommandsAndItsOwnCommands }

        it "must contain the commands defined in the subclass" do
          expect(subject.commands['bar']).to be_kind_of(described_class::Command)
          expect(subject.commands['bar'].name).to eq(:bar)
          expect(subject.commands['bar'].summary).to eq('Bar command')
        end

        it "must also contain the commands defined in the superclass" do
          expect(subject.commands['foo']).to be(shell_superclass.commands['foo'])
        end

        it "must not modify the superclass'es .commands" do
          expect(shell_superclass.commands['foo']).to be_kind_of(described_class::Command)
          expect(shell_superclass.commands['foo'].name).to eq(:foo)
          expect(shell_superclass.commands['foo'].summary).to eq('Foo command')

          expect(shell_superclass.commands['bar']).to be(nil)
        end
      end

      context "but the commands defined in the sub-class override those in the superclass" do
        module TestShell
          class ShellThatOverridesInheritedCommands < ShellWithCommands
            shell_name 'test'
            command :foo, summary: 'Overrided foo command'
            def foo
            end
          end
        end

        let(:shell_class) { TestShell::ShellThatOverridesInheritedCommands }

        it "must contain the commands overridden in the sub-class" do
          expect(subject.commands['foo']).to_not be(shell_superclass.commands['foo'])
          expect(subject.commands['foo'].summary).to eq('Overrided foo command')
        end

        it "must not modify the superclass'es .commands" do
          expect(shell_superclass.commands['foo']).to be_kind_of(described_class::Command)
          expect(shell_superclass.commands['foo'].name).to eq(:foo)
          expect(shell_superclass.commands['foo'].summary).to eq('Foo command')
        end
      end
    end
  end

  describe ".parse" do
    subject { described_class }

    let(:command_name) { 'foo' }

    context "when given a single command name" do
      let(:line) { "#{command_name}" }

      it "must return the command name" do
        expect(subject.parse(line)).to eq([command_name])
      end
    end

    context "when given a command name and additional arguments" do
      let(:arg1) { "bar" }
      let(:arg2) { "baz" }
      let(:line) { "#{command_name} #{arg1} #{arg2}" }

      it "must return the command name and an Array of arguments" do
        expect(subject.parse(line)).to eq([command_name, arg1, arg2])
      end

      context "but the arguments are in quotes" do
        let(:line) { "#{command_name} \"#{arg1} #{arg2}\"" }

        it "must keep quoted arguments together" do
          expect(subject.parse(line)).to eq([command_name, "#{arg1} #{arg2}"])
        end
      end
    end
  end

  describe ".complete" do
    module TestShell
      class ShellWithCompletions < Ronin::Core::CLI::Shell
        shell_name 'test'

        command :foo, summary: 'Foo command'
        def foo
        end

        command :bar, completion: %w[arg1 arg2 foo], summary: 'Bar command'
        def bar
        end

        command :baz, summary: 'Baz command'
        def baz
        end
      end
    end

    let(:shell_class) { TestShell::ShellWithCompletions }
    subject { shell_class }

    context "when the input is empty" do
      let(:preposing) { '' }
      let(:word)      { '' }

      it "must return all available command names" do
        expect(subject.complete(word,preposing)).to eq(subject.commands.keys)
      end
    end

    context "when the input does not contain a space" do
      let(:preposing) { ''   }
      let(:word)      { 'ba' }

      it "must return the matching command names" do
        expect(subject.complete(word,preposing)).to eq(%w[bar baz])
      end
    end

    context "when the input does contain a space" do
      context "and the input starts with a known command" do
        let(:command)   { 'bar'         }
        let(:arg)       { "arg"         }
        let(:preposing) { "#{command} " }
        let(:word)      { arg           }

        it "must return the argument values that match the end of the input" do
          expect(subject.complete(word,preposing)).to eq(
            subject.commands[command].completion.select { |value|
              value.start_with?(word)
            }
          )
        end
      end

      context "but the input does not start with a known command" do
        let(:command) { 'does_not_exist' }
        let(:arg)       { "arg"         }
        let(:preposing) { "#{command} " }
        let(:word)      { arg           }

        it "must return nil" do
          expect(subject.complete(word,preposing)).to be(nil)
        end
      end
    end

    context "when the input ends with a space" do
      context "and the input starts with a known command" do
        let(:command) { 'bar' }

        let(:preposing) { "#{command} " }
        let(:word)      { ''            }

        it "must return all possible completion values for the command" do
          expect(subject.complete(word,preposing)).to eq(
            subject.commands[command].completion
          )
        end
      end

      context "but the input does not start with a known command" do
        let(:command) { 'does_not_exist' }

        let(:preposing) { ''      }
        let(:word)      { command }

        it "must return nil" do
          expect(subject.complete(word,preposing)).to eq([])
        end
      end
    end
  end

  module TestShell
    class TestShell < Ronin::Core::CLI::Shell
      shell_name 'test'

      command :foo, summary: 'Foo command'
      def foo
      end

      command :bar, summary: 'Bar command'
      def bar
      end
    end
  end

  let(:shell_class) { TestShell::TestShell }
  subject { shell_class.new }

  describe "#call" do
    context "when the command exists" do
      context "but the command does not accept any arguments" do
        module TestShell
          class ShellWithCommandWithNoArgs < Ronin::Core::CLI::Shell
            shell_name 'test'

            command :cmd, summary: 'Example command'
            def cmd
              puts "#{__method__} called"
            end
          end
        end

        let(:shell_class) { TestShell::ShellWithCommandWithNoArgs }
        let(:name) { 'cmd' }

        context "and no arguments are given" do
          let(:args) { [] }

          it "must call the command method and return true" do
            expect {
              expect(subject.call(name,*args)).to be(true)
            }.to output("#{name} called#{$/}").to_stdout
          end
        end

        context "and one argument is given" do
          let(:arg)  { "foo" }
          let(:args) { [arg] }

          it "must print an error and return false" do
            expect {
              expect(subject.call(name,*args)).to be(false)
            }.to output("#{name}: too many arguments given#{$/}").to_stderr
          end
        end
      end

      context "and the command accepts an argument" do
        module TestShell
          class ShellWithCommandWithArg < Ronin::Core::CLI::Shell
            shell_name 'test'

            command :cmd_with_arg, usage: 'ARG',
                                   summary: 'Example command with arg'
            def cmd_with_arg(arg)
              puts "#{__method__} called: arg=#{arg}"
            end
          end
        end

        let(:shell_class) { TestShell::ShellWithCommandWithArg }
        let(:name) { 'cmd_with_arg' }

        context "and no arguments are given" do
          let(:args) { [] }

          it "must print an error and return false" do
            expect {
              expect(subject.call(name,*args)).to be(false)
            }.to output("#{name}: too few arguments given#{$/}").to_stderr
          end
        end

        context "and one argument is given" do
          let(:arg)  { "foo" }
          let(:args) { [arg] }

          it "must call the command mehtod with the argument and return true" do
            expect {
              expect(subject.call(name,*args)).to be(true)
            }.to output("#{name} called: arg=#{arg}#{$/}").to_stdout
          end
        end

        context "and more than one arguments is given" do
          let(:arg1) { "foo" }
          let(:arg2) { "bar" }
          let(:args) { [arg1, arg2] }

          it "must print an error and return false" do
            expect {
              expect(subject.call(name,*args)).to be(false)
            }.to output("#{name}: too many arguments given#{$/}").to_stderr
          end
        end
      end

      context "and the command accepts multiple arguments" do
        module TestShell
          class ShellWithCommandWithMultipleArgs < Ronin::Core::CLI::Shell
            shell_name 'test'

            command :cmd_with_args, usage: 'ARG1 ARG2',
                                    summary: 'Example command with multiple arg'
            def cmd_with_args(arg1,arg2)
              puts "#{__method__} called: arg1=#{arg1} arg2=#{arg2}"
            end
          end
        end

        let(:shell_class) { TestShell::ShellWithCommandWithMultipleArgs }
        let(:name) { 'cmd_with_args' }

        context "and no arguments are given" do
          let(:args) { [] }

          it "must print an error and return false" do
            expect {
              expect(subject.call(name,*args)).to be(false)
            }.to output("#{name}: too few arguments given#{$/}").to_stderr
          end
        end

        context "and one argument is given" do
          let(:arg)  { "foo" }
          let(:args) { [arg] }

          it "must print an error and return false" do
            expect {
              expect(subject.call(name,*args)).to be(false)
            }.to output("#{name}: too few arguments given#{$/}").to_stderr
          end
        end

        context "and two arguments are given" do
          let(:arg1) { "foo" }
          let(:arg2) { "bar" }
          let(:args) { [arg1, arg2] }

          it "must call the command method and return true" do
            expect {
              expect(subject.call(name,*args)).to be(true)
            }.to output("#{name} called: arg1=#{arg1} arg2=#{arg2}#{$/}").to_stdout
          end
        end

        context "and more than two arguments is given" do
          let(:arg1) { "foo" }
          let(:arg2) { "bar" }
          let(:arg3) { "baz" }
          let(:args) { [arg1, arg2, arg3] }

          it "must print an error and return false" do
            expect {
              expect(subject.call(name,*args)).to be(false)
            }.to output("#{name}: too many arguments given#{$/}").to_stderr
          end
        end
      end

      context "and the command accepts an optional argument" do
        module TestShell
          class ShellWithCommandWithOptionalArg < Ronin::Core::CLI::Shell
            shell_name 'test'

            command :cmd_with_opt_arg, usage: '[ARG]',
                                       summary: 'Example command with optional arg'
            def cmd_with_opt_arg(arg=nil)
              puts "#{__method__} called: arg=#{arg}"
            end
          end
        end

        let(:shell_class) { TestShell::ShellWithCommandWithOptionalArg }
        let(:name) { 'cmd_with_opt_arg' }

        context "and no arguments are given" do
          let(:args) { [] }

          it "must call the command mehtod and return true" do
            expect {
              expect(subject.call(name,*args)).to be(true)
            }.to output("#{name} called: arg=#{$/}").to_stdout
          end
        end

        context "and one argument is given" do
          let(:arg)  { "foo" }
          let(:args) { [arg] }

          it "must call the command mehtod with the argument and return true" do
            expect {
              expect(subject.call(name,*args)).to be(true)
            }.to output("#{name} called: arg=#{arg}#{$/}").to_stdout
          end
        end

        context "and more than one argument is given" do
          let(:arg1) { "foo" }
          let(:arg2) { "bar" }
          let(:args) { [arg1, arg2] }

          it "must print an error and return false" do
            expect {
              expect(subject.call(name,*args)).to be(false)
            }.to output("#{name}: too many arguments given#{$/}").to_stderr
          end
        end
      end

      context "and the command accepts an argument and an optional argument" do
        module TestShell
          class ShellWithCommandWithArgAndOptionalArg < Ronin::Core::CLI::Shell
            shell_name 'test'

            command :cmd_with_arg_and_opt_arg, usage: 'ARG1 [ARG2]',
                                               summary: 'Example command with arg and optional arg'
            def cmd_with_arg_and_opt_arg(arg1,arg2=nil)
              puts "#{__method__} called: arg1=#{arg1} arg2=#{arg2}"
            end
          end
        end

        let(:shell_class) { TestShell::ShellWithCommandWithArgAndOptionalArg }
        let(:name) { 'cmd_with_arg_and_opt_arg' }

        context "and no arguments are given" do
          let(:args) { [] }

          it "must print an error and return false" do
            expect {
              expect(subject.call(name,*args)).to be(false)
            }.to output("#{name}: too few arguments given#{$/}").to_stderr
          end
        end

        context "and one argument is given" do
          let(:arg)  { "foo" }
          let(:args) { [arg] }

          it "must call the command mehtod with the argument and return true" do
            expect {
              expect(subject.call(name,*args)).to be(true)
            }.to output("#{name} called: arg1=#{arg} arg2=#{$/}").to_stdout
          end
        end

        context "and two arguments are given" do
          let(:arg1) { "foo" }
          let(:arg2) { "bar" }
          let(:args) { [arg1, arg2] }

          it "must call the command mehtod with the argument and return true" do
            expect {
              expect(subject.call(name,*args)).to be(true)
            }.to output("#{name} called: arg1=#{arg1} arg2=#{arg2}#{$/}").to_stdout
          end
        end

        context "and more than two arguments are given" do
          let(:arg1) { "foo" }
          let(:arg2) { "bar" }
          let(:arg3) { "baz" }
          let(:args) { [arg1, arg2, arg3] }

          it "must print an error and return false" do
            expect {
              expect(subject.call(name,*args)).to be(false)
            }.to output("#{name}: too many arguments given#{$/}").to_stderr
          end
        end
      end

      context "and the command accepts a splat of arguments" do
        module TestShell
          class ShellWithCommandWithSplatArgs < Ronin::Core::CLI::Shell
            shell_name 'test'

            command :cmd_with_splat_args, usage: '[ARGS...]',
                                          summary: 'Example command with splat args'
            def cmd_with_splat_args(*args)
              puts "#{__method__} called: args=#{args.join(' ')}"
            end
          end
        end

        let(:shell_class) { TestShell::ShellWithCommandWithSplatArgs }
        let(:name) { 'cmd_with_splat_args' }

        context "and no arguments are given" do
          let(:args) { [] }

          it "must call the command mehtod with no arguments and return true" do
            expect {
              expect(subject.call(name,*args)).to be(true)
            }.to output("#{name} called: args=#{$/}").to_stdout
          end
        end

        context "and one argument is given" do
          let(:arg)  { "foo" }
          let(:args) { [arg] }

          it "must call the command mehtod with the argument and return true" do
            expect {
              expect(subject.call(name,*args)).to be(true)
            }.to output("#{name} called: args=#{arg}#{$/}").to_stdout
          end
        end

        context "and multiple arguments are given" do
          let(:arg1) { "foo" }
          let(:arg2) { "bar" }
          let(:args) { [arg1, arg2] }

          it "must call the command mehtod with the argument and return true" do
            expect {
              expect(subject.call(name,*args)).to be(true)
            }.to output("#{name} called: args=#{arg1} #{arg2}#{$/}").to_stdout
          end
        end
      end

      context "and the command accepts an argument and splat arguments" do
        module TestShell
          class ShellWithCommandWithArgAndSplatArgs < Ronin::Core::CLI::Shell
            shell_name 'test'

            command :cmd_with_arg_and_splat_args, usage: 'ARG [ARGS...]',
                                                  summary: 'Example command with arg and splat args'
            def cmd_with_arg_and_splat_args(arg,*args)
              puts "#{__method__} called: arg=#{arg} args=#{args.join(' ')}"
            end
          end
        end

        let(:shell_class) { TestShell::ShellWithCommandWithArgAndSplatArgs }
        let(:name) { 'cmd_with_arg_and_splat_args' }

        context "and no arguments are given" do
          let(:args) { [] }

          it "must print an error and return false" do
            expect {
              expect(subject.call(name,*args)).to be(false)
            }.to output("#{name}: too few arguments given#{$/}").to_stderr
          end
        end

        context "and one argument is given" do
          let(:arg)  { "foo" }
          let(:args) { [arg] }

          it "must call the command mehtod with the argument and return true" do
            expect {
              expect(subject.call(name,*args)).to be(true)
            }.to output("#{name} called: arg=#{arg} args=#{$/}").to_stdout
          end
        end

        context "and two arguments are given" do
          let(:arg1) { "foo" }
          let(:arg2) { "bar" }
          let(:args) { [arg1, arg2] }

          it "must call the command mehtod with the argument and return true" do
            expect {
              expect(subject.call(name,*args)).to be(true)
            }.to output("#{name} called: arg=#{arg1} args=#{arg2}#{$/}").to_stdout
          end
        end

        context "and more than two arguments are given" do
          let(:arg1) { "foo" }
          let(:arg2) { "bar" }
          let(:arg3) { "baz" }
          let(:args) { [arg1, arg2, arg3] }

          it "must call the command mehtod with the argument and return true" do
            expect {
              expect(subject.call(name,*args)).to be(true)
            }.to output("#{name} called: arg=#{arg1} args=#{arg2} #{arg3}#{$/}").to_stdout
          end
        end
      end

      context "and the command accepts an optional argument and splat arguments" do
        module TestShell
          class ShellWithCommandWithOptionalArgAndSplatArgs < Ronin::Core::CLI::Shell
            shell_name 'test'

            command :cmd_with_opt_arg_and_splat_args, usage: '[ARG] [ARGS...]',
                                                      summary: 'Example command with arg and splat args'
            def cmd_with_opt_arg_and_splat_args(arg=nil,*args)
              puts "#{__method__} called: arg=#{arg} args=#{args.join(' ')}"
            end
          end
        end

        let(:shell_class) { TestShell::ShellWithCommandWithOptionalArgAndSplatArgs }
        let(:name) { 'cmd_with_opt_arg_and_splat_args' }

        context "and no arguments are given" do
          let(:args) { [] }

          it "must call the command method with no arguments and return true" do
            expect {
              expect(subject.call(name,*args)).to be(true)
            }.to output("#{name} called: arg= args=#{$/}").to_stdout
          end
        end

        context "and one argument is given" do
          let(:arg)  { "foo" }
          let(:args) { [arg] }

          it "must call the command mehtod with the argument and return true" do
            expect {
              expect(subject.call(name,*args)).to be(true)
            }.to output("#{name} called: arg=#{arg} args=#{$/}").to_stdout
          end
        end

        context "and two arguments are given" do
          let(:arg1) { "foo" }
          let(:arg2) { "bar" }
          let(:args) { [arg1, arg2] }

          it "must call the command mehtod with the argument and return true" do
            expect {
              expect(subject.call(name,*args)).to be(true)
            }.to output("#{name} called: arg=#{arg1} args=#{arg2}#{$/}").to_stdout
          end
        end

        context "and more than two arguments are given" do
          let(:arg1) { "foo" }
          let(:arg2) { "bar" }
          let(:arg3) { "baz" }
          let(:args) { [arg1, arg2, arg3] }

          it "must call the command mehtod with the argument and return true" do
            expect {
              expect(subject.call(name,*args)).to be(true)
            }.to output("#{name} called: arg=#{arg1} args=#{arg2} #{arg3}#{$/}").to_stdout
          end
        end
      end
    end

    context "when the command does not exist" do
      let(:name) { "does_not_exist" }

      it "must print an error message and return false" do
        expect {
          expect(subject.call(name)).to be(false)
        }.to output("unknown command: #{name}#{$/}").to_stderr
      end
    end

    context "when the command was defined but no method is defined" do
      module TestShell
        class ShellWithCommandButNoMethod < Ronin::Core::CLI::Shell

          command 'cmd', summary: 'Test command'

        end
      end

      let(:shell_class) { TestShell::ShellWithCommandButNoMethod }
      let(:name) { 'cmd' }

      it "must raise NotImplementedError" do
        expect {
          subject.call(name)
        }.to raise_error(NotImplementedError,"#{shell_class}##{name} was not defined for the #{name.inspect} command")
      end
    end
  end

  describe "#command_missing" do
    let(:name) { "foo" }

    it "must print an error message and return false" do
      expect {
        expect(subject.command_missing(name)).to be(false)
      }.to output("unknown command: #{name}#{$/}").to_stderr
    end
  end

  describe "#command_not_found" do
    let(:name) { "foo" }

    it "must print an error message and return false" do
      expect {
        subject.command_not_found(name)
      }.to output("unknown command: #{name}#{$/}").to_stderr
    end
  end

  describe "#help" do
    module TestShell
      class ShellWithCommandsWithoutUsages < Ronin::Core::CLI::Shell
        shell_name 'test'

        command :foo, summary: 'Foo command'
        def foo
        end

        command :bar, summary: 'Bar command'
        def bar
        end
      end

      class ShellWithCommandsWithCustomUsages < Ronin::Core::CLI::Shell
        shell_name 'test'

        command :foo, usage: 'ARG',
                      summary: 'Foo command'
        def foo(arg)
        end

        command :bar, usage: 'ARG1 [ARG2]',
                      summary: 'Bar command'
        def bar(arg1,arg2=nil)
        end
      end
    end

    context "when called with no arguments" do
      context "but the shell has no commands" do
        let(:shell_class) { TestShell::ShellWithNoCommands }

        it "must list the help command" do
          expect {
            subject.help
          }.to output(
            [
              "  help [COMMAND]\tPrints the list of commands or additional help",
              ''
            ].join($/)
          ).to_stdout
        end
      end

      context "but the commands do not have usage strings" do
        let(:shell_class) { TestShell::ShellWithCommandsWithoutUsages }

        it "must print the command names and summaries in two columns" do
          expect {
            subject.help
          }.to output(
            [
              "  help [COMMAND]\tPrints the list of commands or additional help",
              "  foo           \tFoo command",
              "  bar           \tBar command",
              ''
            ].join($/)
          ).to_stdout
        end
      end

      context "when the commands defines custom usages" do
        let(:shell_class) { TestShell::ShellWithCommandsWithCustomUsages }

        it "must print the custom usages next to the command names with extra right-padding" do
          expect {
            subject.help
          }.to output(
            [
              "  help [COMMAND] \tPrints the list of commands or additional help",
              "  foo ARG        \tFoo command",
              "  bar ARG1 [ARG2]\tBar command",
              ''
            ].join($/)
          ).to_stdout
        end
      end
    end

    context "when called with a command name" do
      let(:command) { 'bar' }

      context "but the command does not have a usage string" do
        context "nor does the command have any additional help output" do
          let(:shell_class) { TestShell::ShellWithCommandsWithoutUsages }

          it "must print the command's name and summary" do
            expect {
              subject.help(command)
            }.to output(
              [
                "usage: bar",
                '',
                'Bar command',
                ''
              ].join($/)
            ).to_stdout
          end
        end

        context "and the command has additional help output" do
          module TestShell
            class ShellWithCommandsWithNoUsagesButWithHelp < Ronin::Core::CLI::Shell
              shell_name 'test'

              command :foo, summary: 'Foo command',
                            help: 'The foo command that does things.'
              def foo
              end

              command :bar, summary: 'Bar command',
                            help: 'The bar command that does things.'
              def bar
              end
            end
          end

          let(:shell_class) { TestShell::ShellWithCommandsWithNoUsagesButWithHelp }

          it "must print the command name and additional help output" do
            expect {
              subject.help(command)
            }.to output(
              [
                "usage: bar",
                '',
                'The bar command that does things.',
                ''
              ].join($/)
            ).to_stdout
          end
        end
      end

      context "and the command does have a usage string" do
        context "but the command does not have any additional help output" do
          let(:shell_class) { TestShell::ShellWithCommandsWithCustomUsages }

          it "must print the command name, usage, and summary" do
            expect {
              subject.help(command)
            }.to output(
              [
                "usage: bar ARG1 [ARG2]",
                '',
                'Bar command',
                ''
              ].join($/)
            ).to_stdout
          end
        end

        context "and the command does have any additional help output" do
          module TestShell
            class ShellWithCommandsWithUsagesButWithHelp < Ronin::Core::CLI::Shell
              shell_name 'test'

              command :foo, usage:   'ARG',
                            summary: 'Foo command',
                            help:    'The foo command that does things.'
              def foo(arg)
              end

              command :bar, usage:   'ARG1 [ARG2]',
                            summary: 'Bar command',
                            help:    'The bar command that does things.'
              def bar(arg1,arg2=nil)
              end
            end
          end

          let(:shell_class) { TestShell::ShellWithCommandsWithUsagesButWithHelp }

          it "must print the command name, usage, and additional help output" do
            expect {
              subject.help(command)
            }.to output(
              [
                "usage: bar ARG1 [ARG2]",
                '',
                'The bar command that does things.',
                ''
              ].join($/)
            ).to_stdout
          end
        end
      end

      context "but the command name isn't a defined command" do
        let(:command) { 'does_not_exist' }

        it "must print an 'unknown command' error" do
          expect {
            subject.help(command)
          }.to output("help: unknown command: #{command}#{$/}").to_stderr
        end
      end
    end
  end
end
