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
    #
    # @api semipublic
    #
    module Git
      #
      # Queries the git `user.name` variable from `~/.gitconfig`.
      #
      # @return [String, nil]
      #   The value of `user.name` or `nil` if it was not set.
      #
      def self.user_name
        config_value('user.name')
      end

      #
      # Queries the git `user.email` variable from `~/.gitconfig`.
      #
      # @return [String, nil]
      #   The value of `user.email` or `nil` if it was not set.
      #
      def self.user_email
        config_value('user.email')
      end

      #
      # Queries the git `github.user` variable from `~/.gitconfig`.
      #
      # @return [String, nil]
      #   The value of `github.user` or `nil` if it was not set.
      #
      def self.github_user
        config_value('github.user')
      end

      #
      # Queries a git configuration value.
      #
      # @param [String] name
      #   The configuration name.
      #
      # @return [string, nil]
      #   The configuration value or `nil` if nothing was returned.
      #
      def self.config_value(name)
        output = `git config #{name}`.chomp

        if output.empty? then nil
        else                  output
        end
      end
    end
  end
end
