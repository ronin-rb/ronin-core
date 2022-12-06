# frozen_string_literal: true
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
    # A mixin that adds a class registry to a library:
    #
    # ### Example
    #
    # `lib/ronin/exploits.rb`:
    #
    #     require 'ronin/core/class_registry'
    #     
    #     module Ronin
    #       module Exploits
    #         include Ronin::Core::ClassRegistry
    #     
    #         class_dir "#{__dir__}/classes"
    #       end
    #     end
    #
    # `lib/ronin/exploits/exploit.rb`:
    #
    #     module Ronin
    #       module Exploits
    #         class Exploit
    #     
    #           def self.register(name)
    #             Exploits.register(name,self)
    #           end
    #     
    #         end
    #       end
    #     end
    #
    # `lib/ronin/exploits/my_exploit.rb`:
    #
    #     require 'ronin/exploits/exploit'
    #     
    #     module Ronin
    #       module Exploits
    #         class MyExploit < Exploit
    #     
    #           register 'my_exploit'
    #     
    #         end
    #       end
    #     end
    #
    # @api semipublic
    #
    module ClassRegistry
      class ClassNotFound < RuntimeError
      end

      #
      # Extends {ClassMethods}.
      #
      # @param [Module] namespace
      #   The module that is including {ClassRegistry}.
      #
      def self.included(namespace)
        namespace.extend ClassMethods
      end

      module ClassMethods
        #
        # Gets or sets the class directory path.
        #
        # @param [String, nil] new_dir
        #   The new class directory path.
        #
        # @return [String]
        #   The class directory path.
        # 
        # @raise [NotImplementedError]
        #   The `class_dir` method was not defined in the module.
        #
        # @example
        #   class_dir "#{__dir__}/classes"
        #
        def class_dir(new_dir=nil)
          if new_dir
            @class_dir = new_dir
          else
            @class_dir || raise(NotImplementedError,"#{self} did not define a class_dir")
          end
        end

        #
        # Lists all class files within {#class_dir}.
        #
        # @return [Array<String>]
        #   The list of class paths within {#class_dir}.
        #
        def list_files
          paths = Dir.glob('{**/}*.rb', base: class_dir)
          paths.each { |path| path.chomp!('.rb') }
          return paths
        end

        #
        # The class registry.
        #
        # @return [Hash{String => Class}]
        #   The mapping of class `id` and classes.
        #
        def registry
          @registry ||= {}
        end

        #
        # Registers a class with the registry.
        #
        # @param [String] id
        #   The class `id` to be registered.
        #
        # @param [Class] mod
        #   The class to be registered.
        #
        # @example
        #   Exploits.register('myexploit',MyExploit)
        #
        def register(id,mod)
          registry[id] = mod
        end

        #
        # Finds the path for the class `id`.
        #
        # @param [String] id
        #   The class `id`.
        #
        # @return [String, nil]
        #   The path for the module. If the module file does not exist in
        #   {#class_dir} then `nil` will be returned.
        #
        # @example
        #   Exploits.path_for('my_exploit')
        #   # => "/path/to/lib/ronin/exploits/classes/my_exploit.rb"
        #
        def path_for(id)
          path = File.join(class_dir,"#{id}.rb")

          if File.file?(path)
            return path
          end
        end

        #
        # Loads a class from a file.
        #
        # @param [String] file
        #   The file to load.
        #
        # @return [Class]
        #   The loaded class.
        #
        # @raise [ClassNotFound]
        #   The file does not exist or the class `id` was not found within the
        #   file.
        #
        # @raise [LoadError]
        #   A load error curred while requiring the other files required by
        #   the class file.
        #
        def load_class_from_file(file)
          file = File.expand_path(file)

          unless File.file?(file)
            raise(ClassNotFound,"no such file or directory: #{file.inspect}")
          end

          previous_entries = registry.keys
          require(file)
          new_entries = registry.keys - previous_entries

          if new_entries.empty?
            raise(ClassNotFound,"file did not register a class: #{file.inspect}")
          end

          return registry[new_entries.last]
        end

        #
        # Loads a class from the {#class_dir}.
        #
        # @param [String] id
        #   The class `id` to load.
        #
        # @return [Class]
        #   The loaded class.
        #
        # @raise [ClassNotFound]
        #   The class file could not be found within {#class_dir}.or has
        #   a file/registered-name mismatch.
        #
        # @raise [LoadError]
        #   A load error curred while requiring the other files required by
        #   the class file.
        #
        def load_class(id)
          # short-circuit if the module is already loaded
          if (klass = registry[id])
            return klass
          end

          unless (path = path_for(id))
            raise(ClassNotFound,"could not find file for #{id.inspect}")
          end

          previous_entries = registry.keys
          require(path)

          unless (klass = registry[id])
            new_entries = registry.keys - previous_entries

            if new_entries.empty?
              raise(ClassNotFound,"file did not register a class: #{path.inspect}")
            else
              raise(ClassNotFound,"file registered a class with a different id (#{new_entries.map(&:inspect).join(', ')}): #{path.inspect}")
            end
          end

          return klass
        end
      end
    end
  end
end
