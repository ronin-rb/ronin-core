#
# Copyright (c) 2021 Hal Brodigan (postmodern.mod3 at gmail.com)
#
# This file is part of ronin-core.
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

require 'command_kit/printing'
require 'command_kit/colors'
require 'reline'

module Ronin
  module Core
    module CLI
      class Shell

        include CommandKit::Printing
        include CommandKit::Colors

        #
        # The default shell prompt name.
        #
        # @return [String]
        #
        def self.shell_name(new_name=nil)
          if new_name
            @shell_name = new_name
          else
            @shell_name ||= if superclass < Shell
                              superclass.shell_name
                            end
          end
        end

        #
        # Starts the shell and processes each line of input.
        #
        # @param [Array<Object>] arguments
        #   Additional arguments for `initialize`.
        #
        # @param [Hash{Symbol => Object}] kwargs
        #   Additional keyword arguments for `initialize`.
        #
        # @note
        #   The shell will exit if `Ctrl^C` or `Ctrl^D` is pressed.
        #
        def self.start(*arguments,**kwargs)
          shell = new(*arguments,**kwargs)

          Reline.completion_proc = method(:complete)
          use_history = true

          begin
            loop do
              line = Reline.readline("#{shell.prompt} ", use_history)

              if line.nil? # Ctrl^D
                puts
                break
              end

              line.chomp!

              unless line.empty?
                shell.exec(line)
              end
            end
          rescue Interrupt # catch Ctrl^C
          end
        end

        #
        # The partially input being tab completed.
        #
        # @param [String] word
        #   The partial input being tab completed.
        #
        # @param [String] preposing
        #   The optional command name that preceeds the argument that's being
        #   tab completed.
        #
        # @return [Array<String>, nil]
        #   The possible completion values.
        #
        # @abstract
        #
        def self.complete(word,preposing)
        end

        #
        # The shell name used in the prompt.
        #
        # @return [String]
        #
        # @see shell_name
        #
        def shell_name
          self.class.shell_name
        end

        #
        # The shell prompt.
        #
        # @return [String]
        #
        def prompt
          c = colors(stdout)

          "#{c.red(shell_name)}#{c.bold(c.bright_red('>'))}"
        end

        #
        # Executes a command.
        #
        # @param [String] line
        #   The command to execute.
        #
        # @abstract
        #
        def exec(line)
          raise(NotImplementedError,"#{self.class}##{__method__} was not implemented")
        end

      end
    end
  end
end
