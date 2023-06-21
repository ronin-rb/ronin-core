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

require 'json'

module Ronin
  module Core
    module OutputFormats
      #
      # Represents a JSON (`.json`) output format.
      #
      # @api semipublic
      #
      # @since 0.2.0
      #
      class JSON < OutputFormat

        #
        # Initializes the JSON output format.
        #
        # @param [IO] io
        #   The JSON output stream.
        #
        def initialize(io)
          super(io)

          @first_value = true
        end

        #
        # Appends a value to the JSON stream.
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
          unless value.respond_to?(:to_json)
            raise(NotImplementedError,"output value does not define a #to_json method: #{value.inspect}")
          end

          if @first_value
            @io.write("[#{value.to_json}")
            @first_value = false
          else
            @io.write(",#{value.to_json}")
          end

          @io.flush
          return self
        end

        #
        # Closes the JSON output stream.
        #
        def close
          if @first_value
            @io.write("[]")
          else
            @io.write("]")
          end

          super
        end

      end
    end
  end
end
