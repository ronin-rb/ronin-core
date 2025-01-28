# frozen_string_literal: true
#
# Copyright (c) 2021-2025 Hal Brodigan (postmodern.mod3 at gmail.com)
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
      # Adds a {Version::ClassMethods#version version} metadata
      # attribute to a class.
      #
      # ### Example
      #
      #     class MyModule
      #
      #       include Ronin::Core::Metadata::Version
      #
      #       version '0.2'
      #
      #     end
      #
      module Version
        #
        # Adds {ClassMethods} to the class.
        #
        # @param [Class] base
        #   The base class which is including {Version}.
        #
        # @api private
        #
        def self.included(base)
          base.extend ClassMethods
        end

        #
        # Class methods.
        #
        module ClassMethods
          #
          # Gets or sets the version number.
          #
          # @param [String, nil] new_version
          #   The optional new version number to set.
          #
          # @return [String, nil]
          #   The previously set version number.
          #
          # @example Setting the version:
          #   version '0.2'
          #
          # @example Getting the version:
          #   MyModule.version
          #
          def version(new_version=nil)
            if new_version then @version = new_version
            else                @version
            end
          end
        end
      end
    end
  end
end
