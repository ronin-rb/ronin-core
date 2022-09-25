require 'spec_helper'
require 'ronin/core/cli/command_shell'

describe Ronin::Core::CLI::CommandShell do
  describe ".commands" do
    subject { shell_class }

    context "when no commands have been defined in the shell class" do
      module TestCommandShell
        class ShellWithNoCommands < Ronin::Core::CLI::CommandShell
          shell_name 'test'
        end
      end

      let(:shell_class) { TestCommandShell::ShellWithNoCommands }

      it "must return a Hash only containing the help command" do
        expect(subject.commands.keys).to eq(%w[help])
        expect(subject.commands['help']).to be_kind_of(described_class::Command)
      end
    end

    context "when commands have been defined in the shell class" do
      module TestCommandShell
        class ShellWithCommands < Ronin::Core::CLI::CommandShell
          shell_name 'test'

          command :foo, summary: 'Foo command'
          def foo
          end
        end
      end

      let(:shell_class) { TestCommandShell::ShellWithCommands }

      it "must return the Hash of command names and Command classes" do
        expect(subject.commands['foo']).to be_kind_of(described_class::Command)
        expect(subject.commands['foo'].name).to eq(:foo)
        expect(subject.commands['foo'].summary).to eq('Foo command')
      end
    end

    context "but when the commands are defined in the superclass" do
      module TestCommandShell
        class ShellWithInheritedCommands < ShellWithCommands
          shell_name 'test'
        end
      end

      let(:shell_superclass) do
        TestCommandShell::ShellWithCommands
      end

      let(:shell_class) do
        TestCommandShell::ShellWithInheritedCommands
      end

      it "must return the commands defined in the superclass" do
        expect(subject.commands['foo']).to be(shell_superclass.commands['foo'])
      end

      context "but additional commands are defined in the sub-class" do
        module TestCommandShell
          class ShellWithInheritedCommandsAndItsOwnCommands < ShellWithCommands
            shell_name 'test'
            command :bar, summary: 'Bar command'
            def bar
            end
          end
        end

        let(:shell_class) do
          TestCommandShell::ShellWithInheritedCommandsAndItsOwnCommands
        end

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
        module TestCommandShell
          class ShellThatOverridesInheritedCommands < ShellWithCommands
            shell_name 'test'
            command :foo, summary: 'Overrided foo command'
            def foo
            end
          end
        end

        let(:shell_class) { TestCommandShell::ShellThatOverridesInheritedCommands }

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

  describe ".parse_command" do
    subject { described_class }

    let(:command_name) { 'foo' }

    context "when given a single command name" do
      let(:line) { "#{command_name}" }

      it "must return the command name" do
        expect(subject.parse_command(line)).to eq(
          [command_name]
        )
      end
    end

    context "when given a command name and additional arguments" do
      let(:arg1) { "bar" }
      let(:arg2) { "baz" }
      let(:line) { "#{command_name} #{arg1} #{arg2}" }

      it "must return the command name and an Array of arguments" do
        expect(subject.parse_command(line)).to eq(
          [command_name, arg1, arg2]
        )
      end

      context "but the arguments are in quotes" do
        let(:line) { "#{command_name} \"#{arg1} #{arg2}\"" }

        it "must keep quoted arguments together" do
          expect(subject.parse_command(line)).to eq(
            [command_name, "#{arg1} #{arg2}"]
          )
        end
      end
    end
  end

  describe "#complete" do
    module TestCommandShell
      class ShellWithCompletions < Ronin::Core::CLI::CommandShell
        shell_name 'test'

        command :foo, summary: 'Foo command'
        def foo
        end

        command :bar, completions: %w[arg1 arg2 foo], summary: 'Bar command'
        def bar
        end

        command :baz, summary: 'Baz command'
        def baz
        end
      end
    end

    let(:shell_class) { TestCommandShell::ShellWithCompletions }
    subject { shell_class.new }

    context "when the input is empty" do
      let(:preposing) { '' }
      let(:word)      { '' }

      it "must return all available command names" do
        expect(subject.complete(word,preposing)).to eq(subject.class.commands.keys)
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

        context "and the command defines an Array of completion values" do
          it "must return the command's argument values that match the end of the input" do
            expect(subject.complete(word,preposing)).to eq(
              subject.class.commands[command].completions.select { |value|
                value.start_with?(word)
              }
            )
          end

          context "but the input contains multiple spaces" do
            let(:preposing) { "#{command} bla bla "}

            it "must still return the command's argument values that match the end of the input" do
              expect(subject.complete(word,preposing)).to eq(
                subject.class.commands[command].completions.select { |value|
                  value.start_with?(word)
                }
              )
            end
          end
        end

        context "and the command defines a completion method name" do
          module TestCommandShell
            class ShellWithCompletionMethod < Ronin::Core::CLI::CommandShell
              shell_name 'test'

              command :foo, summary: 'Foo command'
              def foo
              end

              command :bar, summary: 'Bar command',
                            completions: :bar_completion
              def bar
              end

              def bar_completion(arg)
                [
                  "#{arg}A",
                  "#{arg}B"
                ]
              end

              command :baz, summary: 'Baz command'
              def baz
              end
            end
          end

          let(:shell_class) { TestCommandShell::ShellWithCompletionMethod }

          it "must call the completion method with the argument" do
            expect(subject.complete(word,preposing)).to eq(
              subject.send(subject.class.commands[command].completions,word)
            )
          end

          context "but the completion method was not defined" do
            module TestCommandShell
              class ShellWithMissingCompletionMethod < Ronin::Core::CLI::CommandShell
                shell_name 'test'

                command :foo, summary: 'Foo command'
                def foo
                end

                command :bar, summary: 'Bar command',
                              completions: :bar_completion
                def bar
                end

                command :baz, summary: 'Baz command'
                def baz
                end
              end
            end

            let(:shell_class) do
              TestCommandShell::ShellWithMissingCompletionMethod
            end

            it "must call the completion method with the argument" do
              expect {
                subject.complete(word,preposing)
              }.to raise_error(NotImplementedError,"#{subject.class}#bar_completion was not defined")
            end
          end
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
            subject.class.commands[command].completions
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

  module TestCommandShell
    class TestCommandShell < Ronin::Core::CLI::CommandShell
      shell_name 'test'

      command :foo, summary: 'Foo command'
      def foo
      end

      command :bar, summary: 'Bar command'
      def bar
      end
    end
  end

  let(:shell_class) { TestCommandShell::TestCommandShell }
  subject { shell_class.new }

  describe "#exec" do
    it "must call the underlying command method" do
      expect(subject).to receive(:foo)

      subject.exec('foo')
    end
  end

  describe "#call" do
    context "when the command exists" do
      context "but the command does not accept any arguments" do
        module TestCommandShell
          class ShellWithCommandWithNoArgs < Ronin::Core::CLI::CommandShell
            shell_name 'test'

            command :cmd, summary: 'Example command'
            def cmd
              puts "#{__method__} called"
            end
          end
        end

        let(:shell_class) do
          TestCommandShell::ShellWithCommandWithNoArgs
        end
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
        module TestCommandShell
          class ShellWithCommandWithArg < Ronin::Core::CLI::CommandShell
            shell_name 'test'

            command :cmd_with_arg, usage: 'ARG',
                                   summary: 'Example command with arg'
            def cmd_with_arg(arg)
              puts "#{__method__} called: arg=#{arg}"
            end
          end
        end

        let(:shell_class) do
          TestCommandShell::ShellWithCommandWithArg
        end
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
        module TestCommandShell
          class ShellWithCommandWithMultipleArgs < Ronin::Core::CLI::CommandShell
            shell_name 'test'

            command :cmd_with_args, usage: 'ARG1 ARG2',
                                    summary: 'Example command with multiple arg'
            def cmd_with_args(arg1,arg2)
              puts "#{__method__} called: arg1=#{arg1} arg2=#{arg2}"
            end
          end
        end

        let(:shell_class) do
          TestCommandShell::ShellWithCommandWithMultipleArgs
        end
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
        module TestCommandShell
          class ShellWithCommandWithOptionalArg < Ronin::Core::CLI::CommandShell
            shell_name 'test'

            command :cmd_with_opt_arg, usage: '[ARG]',
                                       summary: 'Example command with optional arg'
            def cmd_with_opt_arg(arg=nil)
              puts "#{__method__} called: arg=#{arg}"
            end
          end
        end

        let(:shell_class) do
          TestCommandShell::ShellWithCommandWithOptionalArg
        end
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
        module TestCommandShell
          class ShellWithCommandWithArgAndOptionalArg < Ronin::Core::CLI::CommandShell
            shell_name 'test'

            command :cmd_with_arg_and_opt_arg, usage: 'ARG1 [ARG2]',
                                               summary: 'Example command with arg and optional arg'
            def cmd_with_arg_and_opt_arg(arg1,arg2=nil)
              puts "#{__method__} called: arg1=#{arg1} arg2=#{arg2}"
            end
          end
        end

        let(:shell_class) do
          TestCommandShell::ShellWithCommandWithArgAndOptionalArg
        end
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
        module TestCommandShell
          class ShellWithCommandWithSplatArgs < Ronin::Core::CLI::CommandShell
            shell_name 'test'

            command :cmd_with_splat_args, usage: '[ARGS...]',
                                          summary: 'Example command with splat args'
            def cmd_with_splat_args(*args)
              puts "#{__method__} called: args=#{args.join(' ')}"
            end
          end
        end

        let(:shell_class) do
          TestCommandShell::ShellWithCommandWithSplatArgs
        end
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
        module TestCommandShell
          class ShellWithCommandWithArgAndSplatArgs < Ronin::Core::CLI::CommandShell
            shell_name 'test'

            command :cmd_with_arg_and_splat_args, usage: 'ARG [ARGS...]',
                                                  summary: 'Example command with arg and splat args'
            def cmd_with_arg_and_splat_args(arg,*args)
              puts "#{__method__} called: arg=#{arg} args=#{args.join(' ')}"
            end
          end
        end

        let(:shell_class) do
          TestCommandShell::ShellWithCommandWithArgAndSplatArgs
        end
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
        module TestCommandShell
          class ShellWithCommandWithOptionalArgAndSplatArgs < Ronin::Core::CLI::CommandShell
            shell_name 'test'

            command :cmd_with_opt_arg_and_splat_args, usage: '[ARG] [ARGS...]',
                                                      summary: 'Example command with arg and splat args'
            def cmd_with_opt_arg_and_splat_args(arg=nil,*args)
              puts "#{__method__} called: arg=#{arg} args=#{args.join(' ')}"
            end
          end
        end

        let(:shell_class) do
          TestCommandShell::ShellWithCommandWithOptionalArgAndSplatArgs
        end
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

      context "but the command method raises an exception" do
        module TestCommandShell
          class ShellWithCommandThatRaisesAnException < Ronin::Core::CLI::CommandShell

            command 'cmd', summary: 'Test command'
            def cmd
              raise("error!")
            end

          end
        end

        let(:shell_class) do
          TestCommandShell::ShellWithCommandThatRaisesAnException
        end
        let(:name) { 'cmd' }

        it "must print an error message and return false" do
          expect {
            expect(subject.call(name)).to be(false)
          }.to output(/an unhandled exception occurred in the #{name} command/).to_stderr
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
      module TestCommandShell
        class ShellWithCommandButNoMethod < Ronin::Core::CLI::CommandShell

          command 'cmd', summary: 'Test command'

        end
      end

      let(:shell_class) do
        TestCommandShell::ShellWithCommandButNoMethod
      end
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
    module TestCommandShell
      class ShellWithCommandsWithoutUsages < Ronin::Core::CLI::CommandShell
        shell_name 'test'

        command :foo, summary: 'Foo command'
        def foo
        end

        command :bar, summary: 'Bar command'
        def bar
        end
      end

      class ShellWithCommandsWithCustomUsages < Ronin::Core::CLI::CommandShell
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
        let(:shell_class) do
          TestCommandShell::ShellWithNoCommands
        end

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
        let(:shell_class) do
          TestCommandShell::ShellWithCommandsWithoutUsages
        end

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
        let(:shell_class) do
          TestCommandShell::ShellWithCommandsWithCustomUsages
        end

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
          let(:shell_class) do
            TestCommandShell::ShellWithCommandsWithoutUsages
          end

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
          module TestCommandShell
            class ShellWithCommandsWithNoUsagesButWithHelp < Ronin::Core::CLI::CommandShell
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

          let(:shell_class) do
            TestCommandShell::ShellWithCommandsWithNoUsagesButWithHelp
          end

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
          let(:shell_class) do
            TestCommandShell::ShellWithCommandsWithCustomUsages
          end

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
          module TestCommandShell
            class ShellWithCommandsWithUsagesButWithHelp < Ronin::Core::CLI::CommandShell
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

          let(:shell_class) do
            TestCommandShell::ShellWithCommandsWithUsagesButWithHelp
          end

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
