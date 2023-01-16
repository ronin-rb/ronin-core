# frozen_string_literal: true
#
# Copyright (c) 2021-2023 Hal Brodigan (postmodern.mod3 at gmail.com)
#
# ronin-core is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# ronin-core is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
# 
# You should have received a copy of the GNU Lesser General Public License
# along with ronin-core.  If not, see <https://www.gnu.org/licenses/>.
#

require 'ronin/core/cli/shell'
require 'ronin/core/cli/command_shell/command'

require 'shellwords'

module Ronin
  module Core
    module CLI
      #
      # Base class for all custom command shells.
      #
      # ## Example
      #
      #     class HTTPShell < Ronin::Core::CLI::Shell
      #     
      #       shell_name 'http'
      #     
      #       command :get, usage: 'PATH [HEADERS...]',
      #                     summary: 'Sends a GET request'
      #       def get(path,*headers)
      #         # ...
      #       end
      #
      #       command :post, usage: 'PATH DATA [HEADERS...]',
      #                      summary: 'Sends a POST request'
      #       def post(path,data,*headers)
      #         # ...
      #       end
      #     
      #     end
      #     
      #     HTTPShell.start
      #     # http> get /foo
      #
      # @api semipublic
      #
      class CommandShell < Shell

        #
        # The registered shell commands.
        #
        # @return [Hash{String => CommandShell::Command}]
        #   The registered shell commands.
        #
        def self.commands
          @commands ||= if superclass <= CommandShell
                          superclass.commands.dup
                        else
                          {}
                        end
        end

        #
        # Registers a shell command.
        #
        # @param [Symbol] name
        #   The name of the shell command.
        #
        # @param [Symbol] method_name
        #   Optional method name to use. Defaults to the name argument.
        #
        # @param [String, nil] usage
        #   A usage string indicating the shell command's options/arguments.
        #
        # @param [Array<String>, Symbol, nil] completions
        #   The possible tab completion values, or a method name, to complete
        #   the command's arguments.
        #
        # @param [String] summary
        #   A one-line summary of the shell command.
        #
        # @param [String] help
        #   Multi-line help output for the shell command.
        #
        def self.command(name, method_name: name,
                               usage: nil,
                               completions: nil,
                               summary: ,
                               help: summary)
          commands[name.to_s] = Command.new(name, method_name: method_name,
                                                  usage:       usage,
                                                  completions: completions,
                                                  summary:     summary,
                                                  help:        help.strip)
        end

        #
        # Parses a line of input.
        #
        # @param [String] line
        #   A line of input.
        #
        # @return [String, Array<String>]
        #   The command name and any additional arguments.
        #
        def self.parse_command(line)
          Shellwords.shellsplit(line)
        end

        #
        # The partially input being tab completed.
        #
        # @param [String] word
        #   The partial input being tab completed.
        #
        # @param [String] preposing
        #   The optional command name that precedes the argument that's being
        #   tab completed.
        #
        # @return [Array<String>, nil]
        #   The possible completion values.
        #
        # @raise [NotImplementedError]
        #   The command defined a completion method name but the command shell
        #   does not define the complete method name.
        #
        def complete(word,preposing)
          if preposing.empty?
            self.class.commands.keys.select { |name| name.start_with?(word) }
          else
            name = preposing.split(/\s+/,2).first

            if (command = self.class.commands[name])
              completions = case command.completions
                            when Array then command.completions
                            when Symbol
                              unless respond_to?(command.completions)
                                raise(NotImplementedError,"#{self.class}##{command.completions} was not defined")
                              end

                              send(command.completions,word,preposing)
                            end

              if completions
                completions.select { |arg| arg.start_with?(word) }
              end
            end
          end
        end

        #
        # Executes a command.
        #
        # @param [String] command
        #   The command to execute.
        #
        # @return [Boolean]
        #   Indicates whether the command was successfully executed.
        #
        def exec(command)
          call(*self.class.parse_command(command))
        end

        #
        # Invokes the command with the matching name.
        #
        # @param [String] name
        #   The command name.
        #
        # @param [Array<String>] args
        #   Additional arguments for the command.
        #
        # @return [Boolean]
        #   Indicates whether the command was successfully executed.
        #
        # @raise [NotImplementedError]
        #   The method for the command was not defined.
        #
        def call(name,*args)
          unless (command = self.class.commands[name])
            return command_missing(name,*args)
          end

          method_name = command.method_name

          unless respond_to?(method_name,false)
            raise(NotImplementedError,"#{self.class}##{method_name} was not defined for the #{name.inspect} command")
          end

          unless method_arity_check(method_name,args)
            return false
          end

          begin
            send(method_name,*args)
          rescue => error
            print_exception(error)
            print_error "an unhandled exception occurred in the #{name} command"
            return false
          end

          return true
        end

        #
        # Default method that is called when an unknown command is called.
        #
        # @param [String] name
        #
        # @param [Array<String>] args
        #
        def command_missing(name,*args)
          command_not_found(name)
          return false
        end

        #
        # Prints an error message when an unknown command is given.
        #
        # @param [String] name
        #
        def command_not_found(name)
          print_error "unknown command: #{name}"
        end

        command :help, usage:   '[COMMAND]',
                       summary: 'Prints the list of commands or additional help'

        #
        # Prints all commands or help information for the given command.
        #
        # @param [String, nil] command
        #   Optional command name to print help information for.
        #
        def help(command=nil)
          if command then help_command(command)
          else            help_commands
          end
        end

        private

        #
        # Prints a list of all registered commands.
        #
        def help_commands
          command_table = self.class.commands.map do |name,command|
            [command.to_s, command.summary]
          end

          max_command_string = command_table.map { |command_string,summary|
            command_string.length
          }.max

          command_table.each  do |command_string,summary|
            puts "  #{command_string.ljust(max_command_string)}\t#{summary}"
          end
        end

        #
        # Prints help information about a specific command.
        #
        # @param [String] name
        #   The given command name.
        #
        def help_command(name)
          unless (command = self.class.commands[name])
            print_error "help: unknown command: #{name}"
            return
          end

          puts "usage: #{command}"

          if command.help
            puts
            puts command.help
          end
        end

        #
        # Calculates the minimum and maximum number of arguments for a given
        # command method.
        #
        # @param [String] name
        #   The method name.
        #
        # @return [(Integer, Integer)]
        #   The minimum and maximum number of arguments for the method.
        #
        def minimum_maximum_args(name)
          minimum = maximum = 0

          method(name).parameters.each do |(type,arg)|
            case type
            when :req 
              minimum += 1
              maximum += 1
            when :opt  then maximum += 1
            when :rest then maximum = Float::INFINITY
            end
          end

          return minimum, maximum
        end

        #
        # Performs an arity check between the method's number of arguments and
        # the number of arguments given.
        #
        # @param [String] name
        #   The method name to lookup.
        #
        # @param [Array<String>] args
        #   The given arguments.
        #
        # @return [Boolean]
        #   Indicates whether the method can accept the given number of
        #   arguments.
        #
        def method_arity_check(name,args)
          minimum_args, maximum_args = minimum_maximum_args(name)

          if args.length > maximum_args
            print_error "#{name}: too many arguments given"
            return false
          elsif args.length < minimum_args
            print_error "#{name}: too few arguments given"
            return false
          end

          return true
        end

      end
    end
  end
end
