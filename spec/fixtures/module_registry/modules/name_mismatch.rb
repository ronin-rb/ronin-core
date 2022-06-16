module TestModuleRegistry
  module ExampleNamespace
    class LoadedModule

      ExampleNamespace.register_module('different_name',self)

    end
  end
end
