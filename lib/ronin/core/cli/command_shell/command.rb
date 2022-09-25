#
# Copyright (c) 2021-2022 Hal Brodigan (postmodern.mod3 at gmail.com)
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

module Ronin
  module Core
    module CLI
      class CommandShell < Shell
        class Command

          # The command's name.
          #
          # @return [Symbol]
          attr_reader :name

          # The command's method name.
          #
          # @return [Symbol]
          attr_reader :method_name

          # The usage string for the command's arguments.
          #
          # @return [String, nil]
          attr_reader :usage

          # Possible tab completion values for the command's arguments.
          #
          # @return [Array<String>, Symbol, nil]
          attr_reader :completions

          # The command's one-line summary.
          #
          # @return [String]
          attr_reader :summary

          # The command's multi-line help output.
          #
          # @return [String]
          attr_reader :help

          #
          # Initializes a command value object.
          #
          # @param [Symbol] name
          #   The name of the command.
          #
          # @param [Symbol] method_name
          #   The command's method name. Defaults to the name argument.
          #
          # @param [String, nil] usage
          #   The usage string for the command's arguments.
          #
          # @param [Array<String>, Symbol, nil] completions
          #   Potential tab completion values, or a method name, to complete
          #   the command's arguments.
          #
          # @param [String] summary
          #   A single line summary for the command.
          #
          # @param [String] help
          #   Multi-line help information for the command.
          #
          def initialize(name, method_name: name,
                               usage: nil,
                               completions: nil,
                               summary: ,
                               help: summary)
            @name        = name
            @method_name = method_name
            @usage       = usage
            @summary     = summary
            @help        = help
            @completions = completions
          end

          #
          # Converts the command to a String.
          #
          # @return [String]
          #   The command name and the optional usage.
          #
          def to_s
            if @usage
              "#{@name} #{@usage}"
            else
              @name.to_s
            end
          end

        end
      end
    end
  end
end
