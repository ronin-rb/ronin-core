# frozen_string_literal: true
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

module Ronin
  module Core
    module CLI
      module Options
        module Values
          # Supported architecture names and their Symbol equivalents
          ARCHES = {
            'x86'      => :x86,
            'x86-64'   => :x86_64,
            'amd64'    => :x86_64,
            'ia64'     => :ia64,
            'ppc'      => :ppc,
            'ppc64'    => :ppc64,
            'arm'      => :arm,
            'armbe'    => :arm_be,
            'arm64'    => :arm64,
            'arm64be'  => :arm64_be,
            'mips'     => :mips,
            'mipsle'   => :mips_le,
            'mips64'   => :mips64,
            'mips64le' => :mips64_le
          }
        end
      end
    end
  end
end
