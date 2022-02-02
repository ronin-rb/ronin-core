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

require 'command_kit/command'
require 'command_kit/help/man'

module Ronin
  module Core
    module CLI
      #
      # Common base class for all CLI commands.
      #
      # ## Example
      #
      # Define a common CLI command base class for all commands in the
      # `ronin-foo` library:
      #
      #     # lib/ronin/foo/cli/command.rb
      #     require 'ronin/core/cli/command'
      #
      #     module Ronin
      #       module Foo
      #         class CLI
      #           class Command < Core::CLI::Command
      #     
      #             man_dir File.join(__dir__,'..','..','..','..','man')
      #     
      #           end
      #         end
      #       end
      #     end
      #
      # Define a sub-command named `list` under the `ronin-foo` main command:
      #
      #     # lib/ronin/foo/cli/commands/list.rb
      #     require 'ronin/foo/cli/command'
      #     
      #     module Ronin
      #       module Foo
      #         class CLI
      #           module Commands
      #             class List < Command
      #     
      #               usage '[options] [NAME]'
      #     
      #               argument :name, required: false,
      #                               desc:     'Optional name to list'
      #     
      #               description 'Lists all things'
      #     
      #               man_page 'ronin-foo-list.1'
      #     
      #               def run(name=nil)
      #                 # ...
      #               end
      #     
      #             end
      #           end
      #         end
      #       end
      #     end
      #
      class Command < CommandKit::Command

        include CommandKit::Help::Man

      end
    end
  end
end
