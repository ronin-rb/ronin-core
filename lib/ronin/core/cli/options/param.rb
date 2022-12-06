# frozen_string_literal: true
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
    module CLI
      module Options
        #
        # Adds a `-p,--param NAME=VALUE` option for setting param values.
        #
        module Param
          #
          # Adds a `-p,--param NAME=VALUE` option to the command.
          #
          # @param [Class<Command>] command
          #   The command including {Param}.
          #
          def self.included(command)
            command.option :param, short: '-p',
                                   value: {
                                     type: /\A[^=]+=.+\z/,
                                     usage: 'NAME=VALUE',
                                   },
                                   desc: 'Sets a param' do |str|
                                     name, value = str.split('=',2)

                                     @params[name.to_sym] = value
                                   end
          end

          # The set params.
          #
          # @return [Hash{Symbol => String}]
          attr_reader :params

          #
          # Initializes the command and {#params}.
          #
          # @param [Hash{Symbol => Object}] kwargs
          #   Additional keyword arguments.
          #
          def initialize(**kwargs)
            super(**kwargs)

            @params = {}
          end
        end
      end
    end
  end
end
