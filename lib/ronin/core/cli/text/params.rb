# frozen_string_literal: true
#
# Copyright (c) 2021-2025 Hal Brodigan (postmodern.mod3 at gmail.com)
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

require_relative '../../params/types'

module Ronin
  module Core
    module CLI
      module Text
        #
        # Helper methods for generating display text for
        # {Core::Params::Mixin params} defined on a class.
        #
        # @since 0.3.0
        #
        module Params
          #
          # Returns the display name for the param's type.
          #
          # @param [Core::Params::Param] param
          #   The param.
          #
          # @return [String]
          #   The display name for the param's type.
          #
          def param_type_name(param)
            param.type.class.name.split('::').last
          end

          #
          # Returns a placeholder usage value for the given param.
          #
          # @param [Core::Params::Param] param
          #   The param.
          #
          # @return [String]
          #   The placeholder usage value.
          #
          # @note
          #   This method is primarily used to help build example commands
          #   that accept certain params.
          #
          def param_usage(param)
            case param.type
            when Core::Params::Types::Boolean then 'BOOL'
            when Core::Params::Types::Integer then 'NUM'
            when Core::Params::Types::Float   then 'FLOAT'
            when Core::Params::Types::Regexp  then '/REGEX/'
            when Core::Params::Types::URI     then 'URL'
            else
              param.name.upcase
            end
          end
        end
      end
    end
  end
end
