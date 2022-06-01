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
    #
    # @api semipublic
    #
    module Home
      # Path to the user's home directory.
      DIR = Gem.user_home

      # Path to the user's `~/.config/` directory.
      CONFIG_DIR = ENV.fetch('XDG_CONFIG_HOME') do
        File.join(DIR,'.config')
      end

      #
      # @return [String]
      #
      def self.config_dir(subdir)
        File.join(CONFIG_DIR,subdir)
      end

      # Path to the user's `~/.cache/` directory.
      CACHE_DIR = ENV.fetch('XDG_CACHE_HOME') do
        File.join(DIR,'.cache')
      end

      #
      # @return [String]
      #
      def self.cache_dir(subdir)
        File.join(CACHE_DIR,subdir)
      end

      # Path to the user's `~/.local/share` directory.
      LOCAL_SHARE_DIR = ENV.fetch('XDG_DATA_HOME') do
        File.join(DIR,'.local','share')
      end

      #
      # @return [String]
      #
      def self.local_share_dir(subdir)
        File.join(LOCAL_SHARE_DIR,subdir)
      end
    end
  end
end
