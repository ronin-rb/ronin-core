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
      # Adds a {References::ClassMethods#references references} metadata
      # attribute to a class.
      #
      # ### Example
      #
      #     class MyModule
      #     
      #       include Ronin::Core::Metadata::References
      #     
      #       references [
      #         "https://...",
      #         ...
      #       ]
      #     
      #     end
      #
      module References
        #
        # Adds {ClassMethods} to the class.
        #
        # @param [Class] base
        #   The base class which is including {References}.
        #
        # @api private
        #
        def self.included(base)
          base.extend ClassMethods
        end

        #
        # Class-methods.
        #
        module ClassMethods
          #
          # Gets or sets the reference links.
          #
          # @param [Array<String>, nil] new_references
          #   The optional new reference links to set.
          #
          # @return [Array<String>]
          #   The previously set reference links.
          #
          # @example Set the references:
          #   references [
          #     "https://...",
          #     ...
          #   ]
          #
          # @example Get the reference links:
          #   MyModule.references
          #   # => ["https://...", ...]
          #
          def references(new_references=nil)
            if new_references
              @references = references() + new_references
            else
              @references || if superclass.kind_of?(ClassMethods)
                               superclass.references
                             else
                               []
                             end
            end
          end
        end
      end
    end
  end
end
