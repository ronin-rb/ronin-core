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
    #     require 'ronin/core/module_registry'
    #     
    #     module Ronin
    #       module Exploits
    #         include Ronin::Core::ModuleRegistry
    #     
    #         modules_dir "#{__dir__}/modules"
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
    #             Exploits.register_module(name,self)
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
    module ModuleRegistry
      class ModuleNotFound < RuntimeError
      end

      #
      # Extends {ClassMethods}.
      #
      def self.included(base)
        base.extend ClassMethods
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
        #   The `modules_dir` method was not defined in the module.
        #
        # @example
        #   modules_dir "#{__dir__}/modules"
        #
        def modules_dir(new_dir=nil)
          if new_dir
            @modules_dir = new_dir
          else
            @modules_dir || raise(NotImplementedError,"#{self} did not define a modules_dir")
          end
        end

        #
        # Lists all modules within {#modules_dir}.
        #
        # @return [Array<String>]
        #   The list of module names within {#modules_dir}.
        #
        def list_modules
          paths = Dir.glob('{**/}*.rb', base: modules_dir)
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
        def module_registry
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
        #   Exploits.register_module('myexploit',MyExploit)
        #
        def register_module(name,mod)
          module_registry[name] = mod
        end

        #
        # Finds the path for the module name.
        #
        # @param [String] name
        #   The module name.
        #
        # @return [String, nil]
        #   The path for the module. If the module file does not exist in
        #   {#modules_dir} then `nil` will be returned.
        #
        def find_module(name)
          path = File.join(modules_dir,"#{name}.rb")

          if File.file?(path)
            return path
          end
        end

        #
        # Loads a module from the {#modules_dir}.
        #
        # @param [String] name
        #   The module nmae to load.
        #
        # @return [Class]
        #   The loaded module class.
        #
        # @raise [ModuleNotFound]
        #   The module file could not be found within {#modules_dir}.
        #
        def load_module(name)
          # short-circuit if the module is already loaded
          if (mod = module_registry[name])
            return mod
          else
            unless (path = find_module(name))
              raise(ModuleNotFound,"could not find module #{name.inspect}")
            end

            begin
              require path
            rescue LoadError
              raise(ModuleNotFound,"could not load module #{name.inspect}")
            end

            unless (mod = module_registry[name])
              raise(ModuleNotFound,"module with name #{name.inspect} not found in file #{path.inspect}")
            end

            return mod
          end
        end
      end
    end
  end
end
