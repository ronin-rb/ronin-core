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

require_relative 'numeric'

module Ronin
  module Core
    module Params
      module Types
        #
        # Represents a true/false param.
        #
        class Float < Numeric

          #
          # Coerces a value into a Float value.
          #
          # @param [::Float, ::String, #to_f, Object] value
          #   The value to coerce.
          #
          # @return [::Float]
          #   The coerced Float value.
          #
          # @raise [ValidationError]
          #   The value was not a Float, a String, or was not within {#range},
          #   or below {#min}, or above {#max}.
          #
          # @api private
          #
          def coerce(value)
            case value
            when ::Float
              super(value)
            when ::String
              if value =~ /\A[+-]?\d+(?:\.\d+)?\z/
                super(value.to_f)
              else
                raise(ValidationError,"value contains non-numeric characters (#{value.inspect})")
              end
            else
              if value.respond_to?(:to_f)
                super(value.to_f)
              else
                raise(ValidationError,"value does not define a #to_f method (#{value.inspect})")
              end
            end
          end

        end
      end
    end
  end
end
