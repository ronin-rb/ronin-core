#
# Copyright (c) 2021-2022 Hal Brodigan (postmodern.mod3 at gmail.com)
#
# This file is part of ronin-core.
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

require 'ronin/core/params/exceptions'

module Ronin
  module Core
    module Params
      module Types
        #
        # The base type for all command-line argument types.
        #
        # @api private
        #
        class Type

          #
          # The default coerce method.
          #
          # @param [Object] value
          #   The value to coerce.
          #
          # @return [Object]
          #   The coerced value.
          #
          # @raise [ValidationError]
          #   The given value was invalid.
          #
          # @abstract
          #
          def coerce(value)
            raise(NotImplementedError,"#{self.class}##{__method__} method was not implemented")
          end

        end
      end
    end
  end
end
