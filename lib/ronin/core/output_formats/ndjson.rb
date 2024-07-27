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

require_relative 'output_file'

require 'json'

module Ronin
  module Core
    module OutputFormats
      #
      # Represents a newline deliminated JSON (`.ndjson`) output format.
      #
      # @api semipublic
      #
      # @since 0.2.0
      #
      class NDJSON < OutputFile

        #
        # Appends a value to the NDJSON stream.
        #
        # @param [#to_json] value
        #   The value to append.
        #
        # @return [self]
        #
        # @raise [NotImplementedError]
        #   The given value object does not define a `to_json` method.
        #
        def <<(value)
          @io.puts(value.to_json)
          @io.flush
          return self
        end

      end
    end
  end
end
