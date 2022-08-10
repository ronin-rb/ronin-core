require_relative '../base_class'

module ExampleClassRegistry
  class LoadedModule < BaseClass

    register 'different_name'

  end
end
