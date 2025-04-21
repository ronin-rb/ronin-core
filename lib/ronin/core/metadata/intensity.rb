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
    module Metadata
      #
      # Adds an {Intensity::ClassMethods#Intensity intensity} metadata
      # attribute to a class.
      #
      # ### Example
      #
      #     class MyModule
      #
      #       include Ronin::Core::Metadata::Intensity
      #
      #       intensity :active
      #
      #     end
      #
      module Intensity
        #
        # Adds {ClassMethods} to the class.
        #
        # @param [Class] base
        #   The base class which is including {Intensity}.
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
          # Gets or sets the intensity level.
          #
          # @param [:passive, :active, :aggressive, nil] new_intensity
          #   The optional new intensity level to set.
          #
          #   * `:passive` - does not send any network traffic to the target system.
          #   * `:active` - sends a moderate amount of network traffic to the target
          #     system.
          #   * `:aggressive` - sends an excessive amount of network traffic to the
          #     target system and may trigger alerts.
          #
          # @return [:passive, :active, :aggressive]
          #   The previously set intensity level. Defaults to `:active` if not set.
          #
          # @raise [ArgumentError]
          #   The new intensity level was not `:passive`, `:active`, or
          #   `:aggressive`.
          #
          # @example sets the intensity level:
          #   intensity :passive
          #
          def intensity(new_intensity=nil)
            if new_intensity
              case new_intensity
              when :passive, :active, :aggressive
                @intensity = new_intensity
              else
                raise(ArgumentError,"intensity must be :passive, :active, or :aggressive: #{new_intensity.inspect}")
              end
            else
              @intensity || if superclass.kind_of?(ClassMethods)
                              superclass.intensity
                            else
                              :active
                            end
            end
          end
        end
      end
    end
  end
end
