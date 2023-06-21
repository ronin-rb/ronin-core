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

require 'ronin/core/output_formats/output_format'

module Ronin
  module Core
    module OutputFormats
      #
      # Represents a plain-text list of discovered values.
      #
      # @api semipublic
      #
      # @since 0.2.0
      #
      class TXT < OutputFormat

        #
        # Appends a value to the list output stream.
        #
        # @param [#to_s] value
        #   The value to append.
        #
        # @return [self]
        #
        def <<(value)
          @io.puts(value.to_s)
          @io.flush
          return self
        end

      end
    end
  end
end
