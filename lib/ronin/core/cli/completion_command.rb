# frozen_string_literal: true
#
# Copyright (c) 2021-2025 Hal Brodigan (postmodern.mod3 at gmail.com)
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

require_relative 'command'

require 'command_kit/completion/install'

module Ronin
  module Core
    module CLI
      #
      # Common base class for all `ronin-* completion` commands.
      #
      # ## Example
      #
      #     # lib/ronin/foo/cli/commands/completion.rb
      #     require 'ronin/foo/root'
      #     require 'ronin/core/cli/completion_command'
      #
      #     module Ronin
      #       module Foo
      #         class CLI
      #           class Command < Core::CLI::CompletionCommand
      #
      #             man_dir File.join(ROOT,'man')
      #             man_page 'ronin-foo-completion.1'
      #
      #             completion_file File.join(ROOT,'data','completions','ronin-foo')
      #
      #           end
      #         end
      #       end
      #     end
      #
      # @api semipublic
      #
      # @since 0.2.0
      #
      class CompletionCommand < Command

        include CommandKit::Completion::Install

        #
        # Gets or sets the completion file for the `completion` command.
        #
        # @param [String, nil] new_completion_file
        #   The optional path to the completion file.
        #
        # @return [String]
        #   The completion file path.
        #
        # @raise [NotImplementedError]
        #   The command did not set the `completion_file`.
        #
        # @example
        #   completion_file File.join(ROOT,'data','completions','ronin-foo')
        #
        def self.completion_file(new_completion_file=nil)
          if new_completion_file
            @completion_file = new_completion_file
          else
            @completion_file || raise(NotImplementedError,"#{self} did not set completion_file")
          end
        end

        command_name 'completion'

        option :print, desc: 'Prints the shell completion file' do
          @mode = :print
        end

        option :install, desc: 'Installs the shell completion file' do
          @mode = :install
        end

        option :uninstall, desc: 'Uninstalls the shell completion file' do
          @mode = :uninstall
        end

        examples [
          '--print',
          '--install',
          '--uninstall'
        ]

        bug_report_url 'https://github.com/ronin-rb/ronin-core/issues/new'

        # The command mode.
        #
        # @return [:print, :install, :uninstall]
        attr_reader :mode

        #
        # Initializes the `completion` command.
        #
        # @param [Hash{Symbol => Object}] kwargs
        #   Additional keyword arguments for the command.
        #
        def initialize(**kwargs)
          super(**kwargs)

          @mode = :print
        end

        #
        # The `completion` commands registered completion file.
        #
        # @return [String]
        #   The completion file path.
        #
        # @raise [NotImplementedError]
        #   The command did not set the `completion_file`.
        #
        def completion_file
          self.class.completion_file
        end

        #
        # Runs the `completion` command.
        #
        def run
          if shell_type == :fish
            print_error "shell completions for the fish shell are not currently supported"
            exit(-1)
          end

          case @mode
          when :print
            print_completion_file
          when :install
            install_completion_file

            if shell_type == :zsh
              puts "Ensure that you have the following lines added to your ~/.zshrc:"
              puts
              puts "    autoload -Uz +X compinit && compinit"
              puts "    autoload -Uz +X bashcompinit && bashcompinit"
              puts
            end
          when :uninstall
            uninstall_completion_file

            puts "Completion rules successfully uninstalled. Please restart your shell."
          else
            raise(NotImplementedError,"mode not implemented: #{@mode.inspect}")
          end
        end

        #
        # Prints the `completion` command's {completion_file} to stdout.
        #
        # @param [String] completion_file
        #   The path to the completion file to print.
        #
        # @api private
        #
        def print_completion_file(completion_file=self.completion_file)
          super(completion_file)
        end

        #
        # Installs the `completion` command's {completion_file} for the current
        # `SHELL`.
        #
        # @param [String] completion_file
        #   The path to the completion file to install.
        #
        # @api private
        #
        def install_completion_file(completion_file=self.completion_file)
          super(completion_file)
        end

        #
        # Uninstalls the `completion` command's {completion_file}.
        #
        # @param [String] completion_file
        #   The path to the completion file to uninstall.
        #
        # @api private
        #
        def uninstall_completion_file(completion_file=self.completion_file)
          uninstall_completion_file_for(File.basename(completion_file))
        end

      end
    end
  end
end
