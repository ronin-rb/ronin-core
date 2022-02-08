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
    #         module_load_path 'ronin/exploits'
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
        #   The `module_load_path` method was not defined in the module.
        #
        # @example
        #   module_load_path 'ronin/exploits'
        #
        def module_load_path(new_dir=nil)
          if new_dir
            @module_load_path = new_dir
          else
            @module_load_path || raise(NotImplementedError,"#{self} did not define a module_load_path")
          end
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
        # Pre-registers a module with the registry, even though the class has
        # not been loaded yet.
        #
        # @param [String] name
        #   The module name to pre-register.
        #
        def pre_register_module(name)
          module_registry[name] = nil
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
        # Loads a module from the {#module_load_path}.
        #
        # @param [String] name
        #   The module nmae to load.
        #
        # @return [Class]
        #   The loaded module class.
        #
        # @raise [ModuleNotFound]
        #   The module file could not be found within {#module_load_path}.
        #
        def load_module(name)
          # short-circuit if the module is already loaded
          if (mod = module_registry[name])
            return mod
          else
            path = File.join(module_load_path,name)

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

        #
        # Lists all registered or pre-registered modules.
        #
        # @return [Array<String>]
        #   The list of module names.
        #
        def module_names(&block)
          module_registry.keys
        end

        #
        # Searches through the module names for matching module names.
        #
        # @param [String, Regexp] pattern
        #   The substring or regular expression to match against the names.
        #
        # @yield [name]
        #   If a block is given, it will be passed each matching module name.
        #
        # @yieldparam [String] name
        #   A matching name of a registered or pre-registered module.
        #
        # @return [Array<String>]
        #   The matching module names.
        #
        def find_modules(pattern)
          module_names.select { |name| name.match(pattern) }
        end
      end
    end
  end
end
