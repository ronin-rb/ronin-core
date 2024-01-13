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

require 'command_kit/options/verbose'
require 'command_kit/printing/indent'
require 'command_kit/printing/lists'

module Ronin
  module Core
    module CLI
      module Printing
        #
        # Common methods for printing {Core::Metadata} data.
        #
        module Metadata
          include CommandKit::Printing::Indent
          include CommandKit::Printing::Lists

          #
          # Adds a `-v,--verbose` option to the command class.
          #
          # @param [Class<Command>] command
          #   The command class including {Metadata}.
          #
          def self.included(command)
            command.include CommandKit::Options::Verbose
          end

          #
          # The class which defines the authors.
          #
          # @param [Class<Core::Metadata::Authors>] klass
          #
          def print_authors(klass)
            unless klass.authors.empty?
              puts "Authors:"
              puts

              if verbose?
                indent do
                  klass.authors.each do |author|
                    puts "* #{author}"

                    if author.pgp?
                      puts "  * PGP: #{author.pgp}"
                    end

                    if author.website?
                      puts "  * Website: #{author.website}"
                    end

                    if author.blog?
                      puts "  * Blog: #{author.blog}"
                    end

                    if author.github?
                      puts "  * GitHub: #{author.github_url}"
                    end

                    if author.gitlab?
                      puts "  * GitLab: #{author.gitlab_url}"
                    end

                    if author.twitter?
                      puts "  * Twitter: #{author.twitter_url}"
                    end

                    if author.mastodon?
                      puts "  * Mastodon: #{author.mastodon_url}"
                    end

                    if author.discord?
                      puts "  * Discord: #{author.discord}"
                    end
                  end
                end
              else
                indent { print_list(klass.authors) }
              end

              puts
            end
          end

          #
          # The class which defines a description.
          #
          # @param [Class<Core::Metadata::Description>] klass
          #
          def print_description(klass)
            if klass.description
              puts 'Description:'
              puts

              indent do
                klass.description.each_line do |line|
                  puts line
                end
              end

              puts
            end
          end

          #
          # The class that defines references.
          #
          # @param [Class<Core::Metadata::References>] klass
          #
          def print_references(klass)
            unless klass.references.empty?
              puts "References:"
              puts

              indent { print_list(klass.references) }
              puts
            end
          end
        end
      end
    end
  end
end
