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

module Ronin
  module Core
    module Params
      #
      # Represents an individual param.
      #
      # @api semipublic
      #
      class Param

        # The name of the param.
        #
        # @return [Symbol]
        attr_reader :name

        # The param type.
        #
        # @return [Types::Type]
        attr_reader :type

        # Specifies whether the param is required or not.
        #
        # @return [Boolean]
        attr_reader :required

        # The default value or proc for the param.
        #
        # @return [Object, Proc, nil]
        attr_reader :default

        # The description of the param.
        #
        # @return [String]
        attr_reader :desc

        #
        # Initializes the param.
        #
        # @param [Symbol] name
        #   The name of the param.
        #
        # @param [Type] type
        #   The type of the param.
        #
        # @param [Boolean] required
        #   Whether the param is required or not.
        #
        # @param [Object, Proc, nil] default
        #   The optional default value or default value proc for the param.
        #
        # @param [String] desc
        #   A short one-line description of the param.
        #
        # @api private
        #
        def initialize(name,type, required: false, default: nil, desc: )
          @name     = name
          @type     = type
          @required = required
          @default  = default
          @desc     = desc
        end

        #
        # Determines if the param is required.
        #
        # @return [Boolean]
        #
        def required?
          @required
        end

        #
        # Determines if the param has a default value.
        #
        # @return [Boolean]
        #
        def has_default?
          !@default.nil?
        end

        #
        # Returns the default value for the param.
        #
        # @return [Object]
        #
        def default_value
          if @default.respond_to?(:call) then @default.call
          else                                @default.dup
          end
        end

        #
        # Coerces the value for the param.
        #
        # @param [Object] value
        #   The value to coerce.
        #
        # @return [Object]
        #   The coerced value.
        #
        # @raise [ValidationError]
        #   The param requires a non-nil value.
        #
        def coerce(value)
          case value
          when nil
            if required?
              raise(ValidationError,"param requires a non-nil value")
            end
          else
            @type.coerce(value)
          end
        end

      end
    end
  end
end
