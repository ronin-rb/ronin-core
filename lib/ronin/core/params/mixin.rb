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

require 'ronin/core/params/exceptions'
require 'ronin/core/params/param'
require 'ronin/core/params/types'

module Ronin
  module Core
    module Params
      #
      # Allows classes to define configurable parameters.
      #
      # ## Examples
      #
      #     class BaseClass
      #     
      #       include Ronin::Core::Params::Mixin
      #     
      #     end
      #     
      #     class MyModule < BaseClass
      #     
      #       param :str, desc: 'A basic string param'
      #     
      #       param :feature_flag, Boolean, desc: 'A boolean param'
      #     
      #       param :enum, Enum[:one, :two, :three],
      #                    desc: 'An enum param'
      #
      #       param :num1, Integer, desc: 'An integer param'
      #     
      #       param :num2, Integer, default: 42,
      #                            desc: 'A param with a default value'
      #     
      #       param :num3, Integer, default: ->{ rand(42) },
      #                             desc: 'A param with a dynamic default value'
      #     
      #       param :float, Float, 'Floating point param'
      #
      #       param :url, URI, desc: 'URL param'
      #
      #       param :pattern, Regexp, desc: 'Regular Expression param'
      #     
      #     end
      #     
      #     mod = MyModule.new(params: {num1: 1, enum: :two})
      #     mod.params
      #     # => {:num2=>42, :num3=>25, :num1=>1, :enum=>:two}
      #
      # @api semipublic
      #
      module Mixin
        # The boolean param type.
        Boolean = Params::Types::Boolean

        # The enum param type.
        Enum = Params::Types::Enum

        #
        # Adds {ClassMethods} to the given class.
        #
        # @param [Class] base_class
        #   The class which is including {Mixin}.
        #
        # @raise [TypeError]
        #   {Mixin} was inclued into a module instead of a class.
        #
        # @api private
        #
        def self.included(base_class)
          unless base_class.kind_of?(Class)
            raise(TypeError,"#{Mixin} can only be included into classes")
          end

          base_class.extend ClassMethods
        end

        #
        # Class methods.
        #
        module ClassMethods
          #
          # All defined params.
          #
          # @return [Hash{Symbol => Param}]
          #
          # @api private
          #
          def params
            @params ||= if superclass < Mixin
                          superclass.params.dup
                        else
                          {}
                        end
          end

          #
          # Defines a new param.
          #
          # @param [Symbol] name
          #   The name for the new param.
          #
          # @param [Class, Type] type
          #   The type for the new param. Available types are:
          #   * {Types::Boolean Boolean}
          #   * {Types::Enum Enum}
          #   * {Types::String String}
          #   * {Types::Integer Integer}
          #   * {Types::Float Float}
          #   * {Types::Regexp Regexp}
          #   * {Types::URI URI}
          #
          # @param [Boolean] required
          #   Specifies whether the param requires a value or is optional.
          #
          # @param [Object, nil] default
          #   The optional default value for the param.
          #
          # @param [String] desc
          #   The description for the param. All defined params must have a
          #   description.
          #
          # @example Define a basic String param:
          #   param :foo, desc: 'Foo param'
          #
          # @example Define a param with an explicit type:
          #   param :foo, String, desc: 'Foo param'
          #
          # @example Define a required param:
          #   param :foo, required: true, desc: 'A required param'
          #
          # @example Define a String param with a validation regex:
          #   param :foo, String, format: /\A...\z/, desc: 'Foo param'
          #
          # @example Define a boolean param:
          #   param :mode, Boolean
          #
          # @example Define an enum param:
          #   param :mode, Enum[:one, :two, :three]
          #
          # @example Define a Regexp param:
          #   param :pattern, Regexp
          #
          # @example Define a URI param:
          #   param :pattern, URI
          #
          # @example Define a param with a specific type:
          #   param :foo, Integer, desc: 'Foo param'
          #
          # @example Define a param with type validations:
          #   param :foo, Integer, min:  1,
          #                        max:  100,
          #                        desc: 'Foo param'
          #
          # @example Define a param with a default value:
          #   param :foo, Integer, default: 42,
          #                        desc:    'Foo param'
          #
          # @example Define a param with a proc default value:
          #   param :foo, Integer, default: ->{ rand(42) },
          #                        desc:    'Foo param'
          #
          # @api public
          #
          def param(name,type=Types::String.new, required: false,
                                                 default:  nil,
                                                 desc: ,
                                                 **kwargs)
            type = case type
                   when Types::Type then type
                   else                  Types.lookup(type).new(**kwargs)
                   end

            params[name] = Param.new(name,type, required: required,
                                                default:  default,
                                                desc:     desc)
          end
        end

        # The param values.
        # 
        # @return [Hash{Symbol => Object}]
        #
        # @api public
        attr_reader :params

        #
        # Initializes the params.
        #
        # @param [Array] arguments
        #   Additional arguments for the class'es `initialize` method.
        #
        # @param [Hash{Symbol => Object}] params
        #   The param values.
        #
        # @param [Hash{Symbol => Object}] kwargs
        #   Additional keyword arguments for the superclass'es `initialize`
        #   method.
        #
        # @api public
        #
        def initialize(*arguments, params: nil, **kwargs, &block)
          if params then self.params = params
          else           initialize_params()
          end

          super(*arguments,**kwargs,&block)
        end

        #
        # Initializes {#params}.
        #
        # @api semipublic
        #
        def initialize_params
          @params = {}

          self.class.params.each do |name,param|
            @params[name] = param.default_value if param.has_default?
          end
        end

        #
        # Sets a param's value.
        #
        # @param [Symbol] name
        #   The param name.
        #
        # @param [Object] value
        #   The new param value.
        #
        # @raise [ValidationError]
        #   The given param value was invalid.
        #
        # @api semipublic
        #
        def set_param(name,value)
          unless (param = self.class.params[name])
            raise(UnknownParam,"unknown param: #{name.inspect}")
          end

          @params[name] = begin
                            param.coerce(value)
                          rescue ValidationError => error
                            raise(ValidationError,"invalid param value for param '#{name}': #{error.message}")
                          end
        end

        #
        # Sets the params.
        #
        # @param [Hash{Symbol => Object}] new_params
        #   The new param values.
        #
        # @raise [RequiredParam]
        #   One of the required params is not set.
        #
        # @api semipublic
        #
        def params=(new_params)
          initialize_params()

          new_params.each do |name,value|
            set_param(name,value)
          end

          validate_params
          return new_params
        end

        #
        # Validates that all required params are set.
        #
        # @return [true]
        #   Indicates all required params have non-nil values.
        #
        # @raise [RequiredParam]
        #   One of the required params is not set.
        #
        # @api semipublic
        #
        def validate_params
          self.class.params.each do |name,param|
            if param.required? && @params[name].nil?
              raise(RequiredParam,"param '#{name}' requires a value")
            end
          end

          return true
        end
      end
    end
  end
end
