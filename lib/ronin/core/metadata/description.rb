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

module Ronin
  module Core
    module Metadata
      #
      # Adds a {Description::ClassMethods#description description} metadata
      # attribute to a class.
      #
      # ### Example
      #
      #     class MyModule
      #     
      #       include Ronin::Core::Metadata::Description
      #     
      #       description <<~DESC
      #         Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do
      #         eiusmod tempor incididunt ut labore et dolore magna aliqua.
      #
      #         Ut enim ad minim veniam, quis nostrud exercitation ullamco
      #         laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure
      #         dolor in reprehenderit in voluptate velit esse cillum dolore eu
      #
      #         fugiat nulla pariatur. Excepteur sint occaecat cupidatat non
      #         proident, sunt in culpa qui officia deserunt mollit anim id est
      #         laborum.
      #       DESC
      #     
      #     end
      #
      module Description
        #
        # Adds {ClassMethods} to the class.
        #
        # @param [Class] base
        #   The base class which is including {Description}.
        #
        # @api private
        #
        def self.included(base)
          base.extend ClassMethods
        end

        module ClassMethods
          #
          # Gets or sets the description.
          #
          # @param [String, nil] new_description
          #   The optional new description text to set.
          #
          # @return [String, nil]
          #   The previously set description text.
          #
          # @example Setting the description:
          #   description <<~DESC
          #     Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do
          #     eiusmod tempor incididunt ut labore et dolore magna aliqua.
          #
          #     Ut enim ad minim veniam, quis nostrud exercitation ullamco
          #     laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure
          #     dolor in reprehenderit in voluptate velit esse cillum dolore eu
          #
          #     fugiat nulla pariatur. Excepteur sint occaecat cupidatat non
          #     proident, sunt in culpa qui officia deserunt mollit anim id est
          #     laborum.
          #   DESC
          #
          # @example Getting the description:
          #   MyModule.description
          #
          def description(new_description=nil)
            if new_description
              @description = new_description
            else
              @description || if superclass.kind_of?(ClassMethods)
                                superclass.description
                              end
            end
          end
        end
      end
    end
  end
end
