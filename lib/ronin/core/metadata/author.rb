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
    module Metadata
      #
      # Adds a {Author::ClassMethods#author author} metadata attribute to a
      # class.
      #
      # ### Example
      #
      #     class MyModule
      #     
      #       include Ronin::Core::Metadata::Author
      #     
      #       author 'John Smith', 'john.smith@example.com'
      #     
      #     end
      #
      module Author
        def self.included(base)
          base.extend ClassMethods
        end

        module ClassMethods
          #
          # Gets or sets the author.
          #
          # @param [String, nil] new_author_name
          #   The optional new author name to set.
          #
          # @param [String, nil] new_author_email
          #   The optional new author email to set.
          #
          # @return [String, (String, String), nil]
          #   The previously set author name, or name and email.
          #
          # @example Set the author name:
          #   author 'John Smith'
          #
          # @example Set the author name and email:
          #   author 'John Smith', 'john.smith@example.com'
          #
          # @example Getting the author:
          #   MyModule.author
          #   # => ["John Smith", "john.smith@example.com"]
          #
          def author(new_author_name=nil,new_author_email=nil)
            if new_author_name
              @author_name  = new_author_name
              @author_email = new_author_email if new_author_email

              return new_author_name, new_author_email
            else
              if @author_name
                if @author_email then return [@author_name, @author_email]
                else                  return @author_name
                end
              elsif superclass.kind_of?(ClassMethods)
                superclass.author
              end
            end
          end
        end
      end
    end
  end
end
