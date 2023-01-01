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
        # Represents a Regexp type.
        #
        class Regexp < Type

          #
          # Parses the String value.
          #
          # @param [::String, ::Regexp, Object] value
          #   The String value to coerce.
          #
          # @return [Regexp]
          #   The coerced Regexp value.
          #
          # @raise [ValidationError]
          #   The value was not a Regexp, a String, or a String that could not
          #   be parsed by `Regexp.new`.
          #
          # @api private
          #
          def coerce(value)
            case value
            when ::Regexp then value
            when ::String
              unless (value.start_with?('/') && value.end_with?('/'))
                raise(ValidationError,"value must be of the format '/.../' (#{value.inspect})")
              end

              begin
                ::Regexp.new(value[1..-2])
              rescue RegexpError
                raise(ValidationError,"value is not a valid Regexp (#{value.inspect})")
              end
            else
              raise(ValidationError,"value must be either a String or a Regexp (#{value.inspect})")
            end
          end

        end
      end
    end
  end
end
