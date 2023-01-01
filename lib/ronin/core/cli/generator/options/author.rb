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

require 'ronin/core/git'

module Ronin
  module Core
    module CLI
      module Generator
        module Options
          #
          # Adds the `-a,--author NAME` and `-e,--author-email EMAIL` options
          # for the generator command.
          #
          module Author

            #
            # The default author name.
            #
            # @return [String, nil]
            #
            def self.default_name
              Core::Git.user_name || ENV['USERNAME']
            end

            #
            # The default author email.
            #
            # @return [String, nil]
            #
            def self.default_email
              Core::Git.user_email
            end

            #
            # Defines the `-a,--author NAME` and `-e,--author-email EMAIL`
            # options.
            #
            # @param [Class<Comand>] command
            #   The command class including {Author}.
            #
            def self.included(command)
              command.option :author, short: '-a',
                                      value: {
                                        type:    String,
                                        usage:   'NAME',
                                        default: ->{ default_name }
                                      },
                                      desc: 'The name of the author' do |author|
                                        @author_name = author
                                      end

              command.option :author_email, short: '-e',
                                            value: {
                                              type:    String,
                                              usage:   'EMAIL',
                                              default: ->{ default_email }
                                            },
                                            desc: 'The email address of the author' do |email|
                                              @author_email = email
                                            end
            end

            # The author name.
            #
            # @return [String]
            attr_reader :author_name

            # The author email.
            #
            # @return [String]
            attr_reader :author_email

            #
            # Initializes {#author_name} and {#author_email}.
            #
            # @param [Hash{Symbol => Object}] kwargs
            #   Additional keyword arguments.
            #
            def initialize(**kwargs)
              super(**kwargs)

              @author_name  = Author.default_name
              @author_email = Author.default_email
            end
          end
        end
      end
    end
  end
end
