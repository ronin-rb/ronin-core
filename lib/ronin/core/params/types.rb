# frozen_string_literal: true
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

require 'ronin/core/params/exceptions'
require 'ronin/core/params/types/string'
require 'ronin/core/params/types/boolean'
require 'ronin/core/params/types/integer'
require 'ronin/core/params/types/float'
require 'ronin/core/params/types/regexp'
require 'ronin/core/params/types/uri'
require 'ronin/core/params/types/enum'

module Ronin
  module Core
    module Params
      module Types
        # Mapping of ruby core classes to param types.
        TYPE_ALIASES = {
          ::String  => Types::String,
          ::Integer => Types::Integer,
          ::Float   => Types::Float,
          ::Regexp  => Types::Regexp,
          ::URI     => Types::URI,
        }

        #
        # Looks up a type class.
        #
        # @param [Class] type_class
        #   The ruby class to map to a param type class.
        #
        # @return [Class<Types::Type>]
        #   The param type class.
        #
        def self.lookup(type_class)
          if type_class < Type
            type_class
          else
            TYPE_ALIASES.fetch(type_class) do
              raise(UnknownType,"unknown param type: #{type_class.inspect}")
            end
          end
        end
      end
    end
  end
end
