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

module Ronin
  module Core
    module Metadata
      #
      # Adds a {ModuleName::ClassMethods#module_name module_name} metadata
      # attribute to a class.
      #
      # ### Example
      #
      #     class MyModule
      #     
      #       include Ronin::Core::Metadata::ModuleName
      #
      #       module_name 'my_module'
      #
      #     end
      #     
      module ModuleName
        def self.included(base)
          base.extend ClassMethods
        end

        module ClassMethods
          #
          # Gets or sets the module name.
          #
          # @param [String, nil] new_name
          #   The optional new module name to set.
          #
          # @return [String, nil]
          #   The previously set module name.
          #
          # @example Setting the module name:
          #   module_name 'my_module'
          #
          # @example Getting the module name:
          #   MyModule.module_name
          #
          def module_name(new_name=nil)
            if new_name then @module_name = new_name
            else             @module_name
            end
          end
        end
      end
    end
  end
end
