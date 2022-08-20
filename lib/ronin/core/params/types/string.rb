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

require 'ronin/core/params/types/type'

module Ronin
  module Core
    module Params
      module Types
        #
        # Represents a string type.
        #
        class String < Type

          # Optional regexp to validate values with.
          #
          # @return [::Regexp, nil]
          attr_reader :format

          #
          # Initializes the value.
          #
          # @param [::Boolean] allow_empty
          #   Specifies whether the argument may accept empty values.
          #
          # @param [::Boolean] allow_blank
          #   Specifies whether the argument may accept blank values.
          #
          # @param [(::Regexp, ::String), nil] format
          #   Optional regular expression to validate the given param value.
          #
          def initialize(allow_empty: false, allow_blank: false, format: nil)
            @allow_empty = allow_empty
            @allow_blank = allow_blank

            @format = format
          end

          #
          # Specifies whether the param may accept empty values.
          #
          # @return [::Boolean]
          #
          # @api private
          #
          def allow_empty?
            @allow_empty
          end

          #
          # Specifies whether the param may accept blank values.
          #
          # @return [::Boolean]
          #
          # @api private
          #
          def allow_blank?
            @allow_blank
          end

          #
          # Validates the given value.
          #
          # @param [Object] value
          #   The given value to validate.
          #
          # @return [::String]
          #   The coerced String.
          #
          # @raise [ValidationError]
          #   The given value was not a String and did not define a `#to_s`
          #   method, or was a String that did not match {#format}.
          #
          # @api private
          #
          def coerce(value)
            case value
            when Enumerable
              raise(ValidationError,"cannot convert an Enumerable into a String (#{value.inspect})")
            else
              unless value.respond_to?(:to_s)
                raise(ValidationError,"value does not define a #to_s method (#{value.inspect})")
              end

              string = value.to_s

              if @format && !(string =~ @format)
                raise(ValidationError,"does not match the format (#{string.inspect})")
              elsif (string.empty? && !allow_empty?)
                raise(ValidationError,"value cannot be empty")
              elsif (string =~ /\A\s+\z/ && !allow_blank?)
                raise(ValidationError,"value cannot contain all whitespace (#{string.inspect})")
              end

              return string
            end
          end

        end
      end
    end
  end
end
