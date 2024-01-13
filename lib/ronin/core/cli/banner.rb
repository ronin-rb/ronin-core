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
      #
      # Adds a Ronin ASCII art banner to the `--help` output.
      #
      # @since 0.2.0
      #
      module Banner
        # Ronin ASCII art banner.
        BANNER = <<~ASCII
                                                                   , Jµ     ▓▓█▓
                                                  J▌      ▐▓██▌ ████ ██    ▐███D
                                      ╓▄▓▓█████▌  ██µ     ████ ▄███ÖJ██▌   ███▌
        ,╓µ▄▄▄▄▄▄▄▄µ;,            ,▄▓██████████  ▐███    ▐███▀ ███▌ ████µ ▄███
¬∞MÆ▓███████████████████████▓M  ▄██████▀▀╙████▌  ████▌   ████ ▄███ J█████ ███▌
           `█████▀▀▀▀▀███████  -████▀└    ████  ▐█████n ▄███O ███▌ ██████████
           ▓████L       ████▀  ▓████     ▓███Ö  ███████ ███▌ ▓███ ▐█████████▀
          ▄████▀  ,╓▄▄▄█████  J████Ü    ,███▌  ▄███████████ J███▀ ████ █████
         J█████████████████─  ████▌     ████   ████`██████▌ ████ ▐███Ü ▐███Ü
         ███████████▀▀▀╙└    ▐████     J███▌  ▓███▌ ²█████ J███Ü ███▌   ▀█▌
        ▓██████████▌         ████▌     ████  ;████   ▀███▀ ███▌ J▀▀▀-    █
       ▄█████▀ ▀█████µ      ▐████  ,▄▓████▀  ████▀    ███ J███           `
      J█████-    ╙▀███▄     ████████████▀╙  J█▀▀▀      █U  ▀█▌
      ████▀         ▀███   ▄████████▀▀                 ╨    █
     ▓██▀             ²▀█▄ █▀▀▀╙└
    ▄██╜                 ╙W
   J█▀
   ▌└
  ┘
ASCII

        #
        # Prints the Ronin banner.
        #
        def print_banner
          print "#{BANNER}#{$/}"
        end
      end
    end
  end
end
