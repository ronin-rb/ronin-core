require 'ronin/core/class_registry'

module ExampleClassRegistry

  include Ronin::Core::ClassRegistry
  class_dir "#{__dir__}/example_class_registry/classes"

end
