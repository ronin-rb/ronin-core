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

require 'ronin/core/metadata/authors/author'

module Ronin
  module Core
    module Metadata
      #
      # Adds {Authors::ClassMethods#author authors} metadata attribute to a
      # class.
      #
      # ### Example
      #
      #     class MyModule
      #
      #       include Ronin::Core::Metadata::Authors
      #
      #       author 'John Doe'
      #       author 'John Smith', email: 'john.smith@example.com'
      #
      #     end
      #
      #     puts MyModule.authors
      #     # John Doe
      #     # John Smith <john.smith@example.com>
      #
      module Authors
        #
        # Adds {ClassMethods} to the class.
        #
        # @param [Class] base
        #   The base class which is including {Authors}.
        #
        # @api private
        #
        def self.included(base)
          base.extend ClassMethods
        end

        #
        # Class-methods.
        #
        module ClassMethods
          #
          # The authors associated with the class.
          #
          # @return [Array<Authors::Author>]
          #
          # @api semipublic
          #
          def authors
            @authors ||= if superclass.kind_of?(ClassMethods)
                           superclass.authors.dup
                         else
                           []
                         end
          end

          #
          # Adds an author.
          #
          # @param [String, nil] name
          #   The new author name to add.
          #
          # @param [Hash{Symbol => Object}] kwargs
          #   Additional keyword arguments for {Author#initialize}.
          #
          # @option kwargs [String, nil] :email
          #   The author's email.
          #
          # @option kwargs [String, nil] :pgp
          #   The author's PGP Key ID.
          #
          # @option kwargs [String, nil] :website
          #   The author's website.
          #
          # @option kwargs [String, nil] :blog
          #   The author's blog.
          #
          # @option kwargs [String, nil] :github
          #   The author's GitHub user name.
          #
          # @option kwargs [String, nil] :gitlab
          #   The author's GitLab user name.
          #
          # @option kwargs [String, nil] :twitter
          #   The author's Twitter handle.
          #
          # @option kwargs [String, nil] :discord
          #   The author's Discord handle.
          #
          # @example Adds an author name:
          #   author 'John Smith'
          #
          # @example Adds an author name and email:
          #   author 'John Smith', email: 'john.smith@example.com'
          #
          # @api public
          #
          def author(name,**kwargs)
            authors << Ronin::Core::Metadata::Authors::Author.new(name,**kwargs)
          end
        end
      end
    end
  end
end
