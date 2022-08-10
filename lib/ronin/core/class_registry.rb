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
    # A mixin that adds a module registry to a library:
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
    #         class_dir "#{__dir__}/modules"
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
        # Gets or sets the module directory path.
        #
        # @param [String, nil] new_dir
        #   The new module directory path.
        #
        # @return [String]
        #   The module directory path.
        # 
        # @raise [NotImplementedError]
        #   The `class_dir` method was not defined in the module.
        #
        # @example
        #   class_dir "#{__dir__}/modules"
        #
        def class_dir(new_dir=nil)
          if new_dir
            @class_dir = new_dir
          else
            @class_dir || raise(NotImplementedError,"#{self} did not define a class_dir")
          end
        end

        #
        # Lists all modules within {#class_dir}.
        #
        # @return [Array<String>]
        #   The list of module names within {#class_dir}.
        #
        def list_files
          paths = Dir.glob('{**/}*.rb', base: class_dir)
          paths.each { |path| path.chomp!('.rb') }
          return paths
        end

        #
        # The module registry.
        #
        # @return [Hash{String => Class,nil}]
        #   The mapping of module names and classes. A `nil` value indicates a
        #   module has been pre-registered, but is not yet loaded.
        #
        def registry
          @registry ||= {}
        end

        #
        # Registers a module with the registry.
        #
        # @param [String] name
        #   The module name to be registered.
        #
        # @param [Class] mod
        #   The module class to be registered.
        #
        # @example
        #   Exploits.register('myexploit',MyExploit)
        #
        def register(name,mod)
          registry[name] = mod
        end

        #
        # Finds the path for the module name.
        #
        # @param [String] name
        #   The module name.
        #
        # @return [String, nil]
        #   The path for the module. If the module file does not exist in
        #   {#class_dir} then `nil` will be returned.
        #
        def path_for(name)
          path = File.join(class_dir,"#{name}.rb")

          if File.file?(path)
            return path
          end
        end

        #
        # Loads a module from the {#class_dir}.
        #
        # @param [String] name
        #   The module nmae to load.
        #
        # @return [Class]
        #   The loaded module class.
        #
        # @raise [ClassNotFound]
        #   The module file could not be found within {#class_dir}.or has
        #   a file/registered-name mismatch.
        #
        def load_class(name)
          # short-circuit if the module is already loaded
          if (mod = registry[name])
            return mod
          else
            unless (path = path_for(name))
              raise(ClassNotFound,"could not find file #{name.inspect}")
            end

            previous_entries = registry.keys

            begin
              require path
            rescue LoadError
              raise(ClassNotFound,"could not load file #{name.inspect}")
            end

            unless (mod = registry[name])
              new_entries = registry.keys - previous_entries

              if new_entries.empty?
                raise(ClassNotFound,"file did not register a class: #{path.inspect}")
              else
                raise(ClassNotFound,"file registered a class with a different name (#{new_entries.map(&:inspect).join(', ')}): #{path.inspect}")
              end
            end

            return mod
          end
        end
      end
    end
  end
end
