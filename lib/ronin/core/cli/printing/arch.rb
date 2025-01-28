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
      module Printing
        #
        # Command methods for printing arch IDs.
        #
        module Arch
          # Mapping of architecture IDs to printable names.
          ARCH_NAMES = {
            x86: 'x86',

            x86_64: 'x86-64',
            ia64:   'IA64',
            amd64:  'x86-64',

            ppc:   'PPC',
            ppc64: 'PPC64',

            mips:    'MIPS',
            mips_le: 'MIPS (LE)',
            mips_be: 'MIPS',

            mips64:    'MIPS64',
            mips64_le: 'MIPS64 (LE)',
            mips64_be: 'MIPS64',

            arm:      'ARM',
            arm_le:   'ARM',
            arm_be:   'ARM (BE)',

            arm64:    'ARM64',
            arm64_le: 'ARM64',
            arm64_be: 'ARM64 (BE)'
          }

          #
          # Converts the architecture ID to a printable name.
          #
          # @param [Symbol] arch
          #   The arch ID.
          #
          # @return [String]
          #   The arch display name.
          #
          def arch_name(arch)
            ARCH_NAMES.fetch(arch,&:to_s)
          end
        end
      end
    end
  end
end
