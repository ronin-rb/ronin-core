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

require 'ronin/core/params/types/numeric'

module Ronin
  module Core
    module Params
      module Types
        #
        # Represents a numeric value.
        #
        class Integer < Numeric

          #
          # Coerces a String into an Integer value.
          #
          # @param [::Integer, ::String, #to_i, Object] value
          #   The given value to coerce.
          #
          # @return [::Integer]
          #   The coerced Integer value.
          #
          # @raise [ValidationError]
          #   The value was not an Integer, a String, or was not within
          #   {#range}, or below {#min}, or above {#max}.
          #
          # @api private
          #
          def coerce(value)
            case value
            when ::Integer then super(value)
            when ::String
              case value
              when /\A[+-]?\d+\z/
                super(value.to_i)
              when /\A[+-]?0b[01]+\z/
                super(parse_binary(value))
              when /\A[+-]?(?:0x)?[0-9A-Fa-f]+\z/
                super(parse_hexadecimal(value))
              else
                raise(ValidationError,"value contains non-numeric characters (#{value.inspect})")
              end
            else
              if value.respond_to?(:to_i)
                super(value.to_i)
              else
                raise(ValidationError,"value does not define a #to_i method (#{value.inspect})")
              end
            end
          end

          private

          #
          # Parses a binary string.
          #
          # @param [::String] string
          #
          # @return [::Integer]
          #
          def parse_binary(string)
            integer = string.sub(/\A[+-]?0b/,'').to_i(2)
            integer = -integer if string.start_with?('-')
            integer
          end

          #
          # Parses a hexadecimal string.
          #
          # @param [::String] string
          #
          # @return [::Integer]
          #
          def parse_hexadecimal(string)
            integer = string.sub(/\A[+-]?(?:0x)?/,'').to_i(16)
            integer = -integer if string.start_with?('-')
            integer
          end

        end
      end
    end
  end
end
