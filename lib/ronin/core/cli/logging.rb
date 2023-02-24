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

require 'command_kit/colors'

module Ronin
  module Core
    module CLI
      #
      # Helper methods for printing log messages.
      #
      module Logging
        include CommandKit::Colors

        #
        # Prints an info message to STDOUT.
        #
        # @param [String] message
        #   The message to print.
        #
        def log_info(message)
          puts("#{colors.bold(colors.bright_green('>>>'))} #{colors.bold(colors.white(message))}")
        end

        #
        # Prints a warning message to STDOUT.
        #
        # @param [String] message
        #   The message to print.
        #
        def log_warn(message)
          puts("#{colors.bold(colors.bright_yellow('***'))} #{colors.bold(colors.white(message))}")
        end

        #
        # Prints an error message to STDERR.
        #
        # @param [String] message
        #   The message to print.
        #
        def log_error(message)
          stderr.puts("#{colors(stderr).bold(colors(stderr).bright_red('!!!'))} #{colors(stderr).bold(colors(stderr).white(message))}")
        end
      end
    end
  end
end
