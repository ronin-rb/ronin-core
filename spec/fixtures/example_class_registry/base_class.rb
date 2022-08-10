module ExampleClassRegistry
  class BaseClass

    def self.register(path)
      ExampleClassRegistry.register(path,self)
    end

  end
end
