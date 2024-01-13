# frozen_string_literal: true
#
# Copyright (c) 2021-2024 Hal Brodigan (postmodern.mod3 at gmail.com)
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

require 'ronin/core/cli/banner'

module Ronin
  module Core
    module CLI
      module Help
        #
        # Adds the Ronin ASCII art banner to the `--help` output.
        #
        # @since 0.2.0
        #
        module Banner
          include CLI::Banner

          #
          # Prints the Ronin ASCII art banner and the `--help` output.
          #
          # @note
          #   If `stdout` is not a TTY, the Ronin ASCII art banner will be
          #   omitted.
          #
          def help
            print_banner if stdout.tty?

            super
          end
        end
      end
    end
  end
end
