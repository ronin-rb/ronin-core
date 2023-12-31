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

require 'ronin/core/cli/command'

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
          case @mode
          when :print
            print_completion_file(completion_file)
          when :install
            install_completion_file(completion_file)
          when :uninstall
            uninstall_completion_file_for(File.basename(completion_file))
          else
            raise(NotImplementedError,"mode not implemented: #{@mode.inspect}")
          end
        end

      end
    end
  end
end
