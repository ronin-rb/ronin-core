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

require 'ronin/core/params/types/type'

module Ronin
  module Core
    module Params
      module Types
        #
        # Represents a true/false param.
        #
        class Numeric < Type

          # The optional minimum value.
          #
          # @return [::Integer, nil]
          # 
          # @api private
          attr_reader :min

          # The optional maximum value.
          #
          # @return [::Integer, nil]
          #
          # @api private
          attr_reader :max

          # The optional range of acceptable numbers.
          #
          # @return [Range, nil]
          #
          # @api private
          attr_reader :range

          #
          # Initializes the numeric value.
          #
          # @param [::Integer, nil] min
          #   Optional minimum value for the integer param.
          #
          # @param [::Integer, nil] max
          #   Optional maximum value for the integer param.
          #
          # @param [Range] range
          #   Optional range of acceptable integers.
          #
          def initialize(min: nil, max: nil, range: nil)
            @min   = min
            @max   = max
            @range = range
          end

          #
          # Validates a numeric value.
          #
          # @param [::Integer, ::Float] value
          #   The value to validate.
          #
          # @return [::Integer, ::Float]
          #   The validated value.
          #
          # @raise [ValidationError]
          #   The value was not within {#range}, or below {#min}, or above
          #   {#max}.
          #
          # @abstract
          #
          def coerce(value)
            if @range
              unless @range.include?(value)
                raise(ValidationError,"value is not within the range of acceptable values #{@range.begin}-#{@range.end} (#{value.inspect})")
              end
            else
              if @min && (value < @min)
                raise(ValidationError,"value is below minimum value of #{@min} (#{value.inspect})")
              end

              if @max && (value > @max)
                raise(ValidationError,"value is above maximum value of #{@max} (#{value.inspect})")
              end
            end

            return value
          end

        end
      end
    end
  end
end
