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

require_relative 'type'

require 'uri'

module Ronin
  module Core
    module Params
      module Types
        #
        # Represents a URL type.
        #
        class URI < Type

          #
          # Parses the String value.
          #
          # @param [::String, ::URI, Object] value
          #   The String value to coerce.
          #
          # @return [::URI]
          #   The coerced URI value.
          #
          # @raise [ValidationError]
          #   The given value was invalid.
          #
          # @api private
          #
          def coerce(value)
            case value
            when ::URI then value
            when ::String
              if value.empty?
                raise(ValidationError,"value must not be empty")
              end

              unless value =~ /\A[a-z]+:/
                raise(ValidationError,"value must start with a 'scheme:' (#{value.inspect})")
              end

              begin
                ::URI.parse(value)
              rescue ::URI::InvalidURIError
                raise(ValidationError,"value is not a valid URI (#{value.inspect})")
              end
            else
              raise(ValidationError,"value must be either a String or a URI (#{value.inspect})")
            end
          end

        end
      end
    end
  end
end
