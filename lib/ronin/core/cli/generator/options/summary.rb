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
    module CLI
      module Generator
        module Options
          #
          # Adds the `-S,--summary TEXT` option to the generator command.
          #
          module Summary
            #
            # Defines the `-S,--summary TEXT` option.
            #
            # @param [Class<Comand>] command
            #   The command class including {Summary}.
            #
            def self.included(command)
              command.option :summary, short: '-S',
                                       value: {
                                         type: String,
                                         usage: 'TEXT'
                                       },
                                       desc: 'One sentence summary' do |text|
                                         @summary = text
                                       end
            end

            # The summary text to output.
            #
            # @return [String, nil]
            attr_reader :summary
          end
        end
      end
    end
  end
end
