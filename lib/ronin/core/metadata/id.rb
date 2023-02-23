# frozen_string_literal: true
#
# Copyright (c) 2021-2023 Hal Brodigan (postmodern.mod3 at gmail.com)
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
      # Adds a {ID::ClassMethods#id id} metadata attribute to a class.
      #
      # ### Example
      #
      #     class MyClass
      #     
      #       include Ronin::Core::Metadata::ID
      #
      #       id 'my_class'
      #
      #     end
      #     
      module ID
        #
        # Adds {ClassMethods} to the class.
        #
        # @param [Class] base
        #   The base class which is including {ID}.
        #
        # @private
        #
        def self.included(base)
          base.extend ClassMethods
        end

        #
        # Class-methods.
        #
        module ClassMethods
          #
          # Gets or sets the class `id`.
          #
          # @param [String, nil] new_id
          #   The optional new class `id` to set.
          #
          # @return [String, nil]
          #   The previously set class `id`.
          #
          # @example Setting the class `id`:
          #   class MyClass
          #     include Ronin::Core::Metadata::ID
          #     id 'my_class'
          #   end
          #
          # @example Getting the class `id`:
          #   MyClass.id
          #   # => "my_class"
          #
          def id(new_id=nil)
            if new_id then @id = new_id
            else           @id
            end
          end
        end

        #
        # The {ClassMethods#id id} of the class.
        #
        # @return [String, nil]
        #
        # @see ClassMethods#id
        #
        def class_id
          self.class.id
        end
      end
    end
  end
end
