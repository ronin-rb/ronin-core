module TestModuleRegistry
  module ExampleNamespace
    class LoadedModule

      ExampleNamespace.register_module('loaded_module',self)

    end
  end
end
