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

module Ronin
  module Core
    module CLI
      module Text
        #
        # Helper methods for generating display names for Operating System (OS)
        # IDs.
        #
        # @since 0.3.0
        #
        module OS
          # Mapping of Operating System (OS) IDs to display names.
          OS_NAMES = {
            unix:  'UNIX',

            bsd:     'BSD',
            freebsd: 'FreeBSD',
            openbsd: 'OpenBSD',
            netbsd:  'NetBSD',

            linux:   'Linux',
            macos:   'macOS',
            windows: 'Windows'
          }

          #
          # Converts the Operating System (OS) ID to a display name.
          #
          # @param [Symbol] os
          #   The OS ID.
          #
          # @return [String]
          #   The display name for the OS ID.
          #
          def os_name(os)
            OS_NAMES.fetch(os,&:to_s)
          end
        end
      end
    end
  end
end
