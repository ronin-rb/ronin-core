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

require_relative '../../params/types'

require 'command_kit/printing/tables'

module Ronin
  module Core
    module CLI
      module Printing
        #
        # Handles printing {Core::Params::Mixin params} defined on a class.
        #
        module Params
          include CommandKit::Printing::Tables

          # The params table header.
          PARAM_TABLE_HEADER = %w[Name Type Required Default Description]

          #
          # Prints the params defined in the given class.
          #
          # @param [Class<Core::Params::Mixin>] klass
          #   The class which contains the params.
          #
          def print_params(klass)
            return if klass.params.empty?

            rows = []

            klass.params.each do |name,param|
              param_type  = param.type.class.name.split('::').last
              required    = if param.required? then 'Yes'
                            else                    'No'
                            end
              default     = param.default_value
              description = param_description(param)

              rows << [name, param_type, required, default, description]
            end

            puts "Params:"
            puts

            indent do
              print_table(rows,header: PARAM_TABLE_HEADER, border: :line)
            end

            puts
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
          # @since 0.2.0
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

          #
          # Returns the description text for the given param.
          #
          # @param [Core::Params::Param] param
          #   The param.
          #
          # @return [String]
          #   The description text.
          #
          # @note
          #   Will list all possible values for {Core::Params::Types::Enum Enum}
          #   type params.
          #
          # @since 0.3.0
          #
          def param_description(param)
            description = param.desc

            case param.type
            when Core::Params::Types::Enum
              description = description.dup

              param.type.values.each do |value|
                description << "#{$/} * #{value}"
              end
            end

            return description
          end
        end
      end
    end
  end
end
