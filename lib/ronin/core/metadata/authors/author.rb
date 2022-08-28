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
    module Metadata
      module Authors
        class Author

          # The author's name.
          #
          # @return [String]
          attr_reader :name

          # The author's email.
          #
          # @return [String, nil]
          attr_reader :email

          # The author's PGP Key ID.
          #
          # @return [String, nil]
          attr_reader :pgp

          # The author's GitHub user name.
          #
          # @return [String, nil]
          attr_reader :github

          # The author's GitLab user name.
          #
          # @return [String, nil]
          attr_reader :gitlab

          # The author's Twitter handle.
          #
          # @return [String, nil]
          attr_reader :twitter

          # The author's Discord handle.
          #
          # @return [String, nil]
          attr_reader :discord

          #
          # Initializes the author.
          #
          # @param [String] name
          #   The author's name.
          #
          # @param [String, nil] email
          #   The author's email.
          #
          # @param [String, nil] pgp
          #   The author's PGP Key ID.
          #
          # @param [String, nil] github
          #   The author's GitHub user name.
          #
          # @param [String, nil] gitlab
          #   The author's GitLab user name.
          #
          # @param [String, nil] twitter
          #   The author's Twitter handle.
          #
          # @param [String, nil] discord
          #   The author's Discord handle.
          #
          def initialize(name, email:   nil,
                               pgp:     nil,
                               github:  nil,
                               gitlab:  nil,
                               twitter: nil,
                               discord: nil)
            @name  = name
            @email = email
            @pgp   = pgp

            @github  = github
            @gitlab  = gitlab
            @twitter = twitter
            @discord = discord
          end

          #
          # Determines if the author has an {#email} set.
          #
          # @return [Boolean]
          #
          def email?
            @email != nil
          end

          #
          # Determines if the author has a {#pgp} Key ID set.
          #
          # @return [Boolean]
          #
          def pgp?
            @pgp != nil
          end

          #
          # Determines if the author has a {#github} user name set.
          #
          # @return [Boolean]
          #
          def github?
            @github != nil
          end

          #
          # Determines if the author has a {#gitlab} user name set.
          #
          # @return [Boolean]
          #
          def gitlab?
            @gitlab != nil
          end

          #
          # Determines if the author has a {#twitter} handle set.
          #
          # @return [Boolean]
          #
          def twitter?
            @twitter != nil
          end

          #
          # Determines if the author has a {#discord} handle set.
          #
          # @return [Boolean]
          #
          def discord?
            @discord != nil
          end

          #
          # Returns the URL to the author's GitHub profile.
          #
          # @return [String, nil]
          #   Returns the URL to the author's GitHub profile, or `nil`
          #   if no {#github} user name has been set.
          #
          def github_url
            "https://github.com/#{@github}" if @github
          end

          #
          # Returns the URL to the author's GitLab profile.
          #
          # @return [String, nil]
          #   Returns the URL to the author's GitLab profile, or `nil`
          #   if no {#gitlab} user name has been set.
          #
          def gitlab_url
            "https://gitlab.com/#{@gitlab}" if @gitlab
          end

          #
          # Returns the URL to the author's Twitter profile.
          #
          # @return [String, nil]
          #   Returns the URL to the author's Twitter profile, or `nil`
          #   if no {#twitter} user name has been set.
          #
          def twitter_url
            "https://twitter.com/#{@twitter.sub(/^@/,'')}" if @twitter
          end

          #
          # Converts the author to a String.
          #
          # @return [String]
          #   The author's name and/or email.
          #
          def to_s
            if @email then "#{@name} <#{@email}>"
            else           @name
            end
          end

        end
      end
    end
  end
end
