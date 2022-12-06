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

require 'ronin/core/params/types'

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
              param_type = param.type.class.name.split('::').last
              required   = if param.required? then 'Yes'
                           else                    'No'
                           end
              default     = param.default_value
              description = param.desc

              rows << [name, param_type, required, default, description]
            end

            puts "Params:"
            puts

            indent do
              print_table(rows,header: PARAM_TABLE_HEADER, border: :line)
            end
          end
        end
      end
    end
  end
end
