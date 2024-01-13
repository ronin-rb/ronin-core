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

require 'ronin/core/params/types/type'

module Ronin
  module Core
    module Params
      module Types
        #
        # Represents a true/false param.
        #
        class Boolean < Type

          #
          # Coerces a value into a boolean value.
          #
          # @param [::String, true, false, nil] value
          #   The value to coerce.
          #
          # @return [true, false, nil]
          #   The coerced boolean value.
          #
          # @raise [ValidationError]
          #   The given value was not `nil`, `true`, `false`, `"true"`, `"false"`, `"yes"`, `"no"`, `"y"`, `"n"`, `"on"`, or `"off"`.
          #
          # @api private
          #
          def coerce(value)
            case value
            when nil         then false
            when true, false then value
            when ::String
              case value
              when /\A(?:true|yes|y|on)\z/i  then true
              when /\A(?:false|no|n|off)\z/i then false
              else
                raise(ValidationError,"value must be either 'true', 'false', 'yes', 'no', 'y', 'n', 'on', or 'off' (#{value.inspect})")
              end
            else
              raise(ValidationError,"value must be either true, false, or a String (#{value.inspect})")
            end
          end

        end
      end
    end
  end
end
