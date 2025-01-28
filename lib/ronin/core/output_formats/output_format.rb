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
    module OutputFormats
      #
      # Base class for all output formats.
      #
      # @api semipublic
      #
      # @since 0.2.0
      #
      class OutputFormat

        #
        # Writes a value to the output format.
        #
        # @param [Object] value
        #   The output value object to write.
        #
        # @return [self]
        #
        # @abstract
        #
        def <<(value)
          raise(NotImplementedError,"#{self.class}#<< was not implemented")
        end

      end
    end
  end
end
