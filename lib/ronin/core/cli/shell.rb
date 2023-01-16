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
        # @param [String, nil] new_name
        #   The optional new shell prompt name to set.
        #
        # @return [String]
        #   The shell prompt name.
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
        # The default prompt sigil.
        #
        # @param [String, nil] new_sigil
        #   The optional new prompt sigil to use.
        #
        # @return [String]
        #   The prompt sigil.
        #
        def self.prompt_sigil(new_sigil=nil)
          if new_sigil
            @prompt_sigil = new_sigil
          else
            @prompt_sigil ||= if superclass <= Shell
                              superclass.prompt_sigil
                              end
          end
        end

        prompt_sigil '>'

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

          Reline.completion_proc = shell.method(:complete)
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
                begin
                  shell.exec(line)
                rescue SystemExit
                  break
                rescue => error
                  shell.print_exception(error)
                end
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
        #   The optional command name that precedes the argument that's being
        #   tab completed.
        #
        # @return [Array<String>, nil]
        #   The possible completion values.
        #
        # @abstract
        #
        def complete(word,preposing)
        end

        # The shell's name.
        #
        # @return [String, nil]
        attr_reader :shell_name

        # The prompt sigil character (ex: `>`).
        #
        # @return [String]
        attr_reader :prompt_sigil

        #
        # Initializes the shell instance.
        #
        # @param [String, nil] shell_name
        #   The optional shell name to override {shell_name}.
        #
        # @param [String] prompt_sigil
        #   The optional prompt sigil to override {prompt_sigil}.
        #
        def initialize(shell_name:   self.class.shell_name,
                       prompt_sigil: self.class.prompt_sigil,
                       **kwargs)
          super(**kwargs)

          @shell_name   = shell_name
          @prompt_sigil = prompt_sigil
        end

        #
        # The shell prompt.
        #
        # @return [String]
        #
        def prompt
          c = colors(stdout)

          "#{c.red(shell_name)}#{c.bold(c.bright_red(prompt_sigil))}"
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
