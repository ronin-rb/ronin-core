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

require 'csv'

module Ronin
  module Core
    module OutputFormats
      #
      # Represents a CSV (`.csv`) output format.
      #
      # @api semipublic
      #
      # @since 0.2.0
      #
      class CSV < OutputFormat

        #
        # Appends a value to the CSV stream.
        #
        # @param [#to_csv] value
        #   The value to append.
        #
        # @raise [NotImplementedError]
        #   The given output value does not define a `to_csv` method.
        #
        def <<(value)
          unless value.respond_to?(:to_csv)
            raise(NotImplementedError,"output value must define a #to_csv method: #{value.inspect}")
          end

          @io.write(value.to_csv)
          @io.flush

          return self
        end

      end
    end
  end
end
