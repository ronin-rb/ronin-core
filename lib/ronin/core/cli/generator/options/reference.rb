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

module Ronin
  module Core
    module CLI
      module Generator
        module Options
          #
          # Adds the `-R,--reference URL` option to the generator command.
          #
          module Reference
            def self.included(command)
              command.option :reference, short: '-R',
                                         value: {
                                           type: String,
                                           usage: 'URL'
                                         },
                                         desc: 'Adds a reference URL' do |url|
                                           @references << url
                                         end
            end

            # The reference URLs to output.
            #
            # @return [Array<String>]
            attr_reader :references

            #
            # Initializes {#references}.
            #
            # @param [Hash{Symbol => Object}] kwargs
            #   Additional keyword arguments.
            #
            def initialize(**kwargs)
              super(**kwargs)

              @references = []
            end
          end
        end
      end
    end
  end
end
