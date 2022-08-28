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
      # Adds a {Summary::ClassMethods#summary summary} metadata
      # attribute to a class.
      #
      # ### Example
      #
      #     class MyModule
      #     
      #       include Ronin::Core::Metadata::Summary
      #     
      #       summary "Lorem ipsum dolor sit amet, consectetur adipiscing elit"
      #     
      #     end
      #
      module Summary
        #
        # Adds {ClassMethods} to the class.
        #
        # @param [Class] base
        #   The base class which is including {Summary}.
        #
        # @api private
        #
        def self.included(base)
          base.extend ClassMethods
        end

        module ClassMethods
          #
          # Gets or sets the summary.
          #
          # @param [String, nil] new_summary
          #   The optional new summary text to set.
          #
          # @return [String, nil]
          #   The previously set summary text.
          #
          # @example Setting the summary:
          #   summary "Lorem ipsum dolor sit amet, consectetur adipiscing elit" 
          #
          # @example Getting the summary:
          #   MyModule.summary
          #
          def summary(new_summary=nil)
            if new_summary
              @summary = new_summary
            else
              @summary || if superclass.kind_of?(ClassMethods)
                                superclass.summary
                              end
            end
          end
        end
      end
    end
  end
end
