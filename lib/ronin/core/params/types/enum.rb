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

require 'ronin/core/params/types/type'

module Ronin
  module Core
    module Params
      module Types
        #
        # Represents a mapping of Ruby values to their String equivalents.
        #
        class Enum < Type

          # The values of the enum.
          #
          # @return [Array<Object>]
          #
          # @api semipublic
          attr_reader :values

          #
          # Initializes the enum type.
          #
          # @param [Array<Object>] values
          #   The values of the enum type.
          #
          # @raise [ArgumentError]
          #   Cannot initialize an enum type with an empty Array of values.
          #
          # @api semipublic
          #
          def initialize(values)
            if values.empty?
              raise(ArgumentError,"cannot initialize an empty Enum")
            end

            @values = values
            @map    = Hash[values.map { |value| [value.to_s, value] }]
          end

          #
          # Creates a new enum.
          #
          # @param [Array<Object>] values
          #   List of enum values.
          #
          # @return [Enum]
          #   The newly created enum object.
          #
          # @api public
          #
          def self.[](*values)
            new(values)
          end

          #
          # Coerces the value into one of the enum values.
          #
          # @param [::String, ::Symbol, Object] value
          #
          # @return [Symbol]
          #   The coerced value.
          #
          # @raise [ValidationError]
          #   The value was not a valid enum value or a String that maps to an
          #   enum value.
          #
          # @api private
          #
          def coerce(value)
            case value
            when ::Symbol
              unless @values.include?(value)
                raise(ValidationError,"unknown value (#{value.inspect})")
              end

              value
            when ::String
              @map.fetch(value) do
                raise(ValidationError,"unknown value (#{value.inspect})")
              end
            else
              raise(ValidationError,"value must be either a Symbol or a String (#{value.inspect})")
            end
          end

        end
      end
    end
  end
end
