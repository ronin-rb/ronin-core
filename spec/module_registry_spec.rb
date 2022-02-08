require 'spec_helper'
require 'ronin/core/module_registry'

describe Ronin::Core::ModuleRegistry do
  let(:fixtures_dir) { File.join(__dir__,'fixtures') }
  let(:mock_lib_dir) { File.join(fixtures_dir,'module_registry') }

  before { $LOAD_PATH.unshift(mock_lib_dir) }

  describe ".module_load_path" do
    context "when a module_load_path has been defined" do
      module TestModuleRegistry
        module WithAModuleLoadPath
          include Ronin::Core::ModuleRegistry

          module_load_path 'test/dir'
        end
      end

      subject { TestModuleRegistry::WithAModuleLoadPath }

      it "must return the previously set .module_load_path" do
        expect(subject.module_load_path).to eq('test/dir')
      end
    end

    context "but when no module_load_path has been defined" do
      module TestModuleRegistry
        module WithNoModuleLoadPath
          include Ronin::Core::ModuleRegistry
        end
      end

      subject { TestModuleRegistry::WithNoModuleLoadPath }

      it do
        expect {
          subject.module_load_path
        }.to raise_error(NotImplementedError,"#{subject} did not define a module_load_path")
      end
    end
  end

  module TestModuleRegistry
    module ExampleNamespace
      include Ronin::Core::ModuleRegistry
      module_load_path 'example_namespace'
    end
  end

  subject { TestModuleRegistry::ExampleNamespace }

  describe ".module_registry" do
    it "must default to {}" do
      expect(subject.module_registry).to eq({})
    end
  end

  describe ".pre_register_module" do
    let(:name) { 'foo' }

    before { subject.pre_register_module(name) }

    it "must add the module name as a key and nil value to .module_registry" do
      expect(subject.module_registry).to have_key(name)
      expect(subject.module_registry[name]).to be(nil)
    end

    after { subject.module_registry.clear }
  end

  describe ".register_module" do
    module TestModuleRegistry
      module ExampleNamespace
        class Foo
        end
      end
    end

    let(:name) { 'foo' }
    let(:mod)  { TestModuleRegistry::ExampleNamespace::Foo }

    before { subject.register_module(name,mod) }

    it "must add the module name and module to #module_registry" do
      expect(subject.module_registry[name]).to be(mod)
    end

    after { subject.module_registry.clear }
  end

  describe ".load_module" do
    let(:name) { 'loaded_module' }
    let(:mod)  { TestModuleRegistry::ExampleNamespace::LoadedModule }

    it "must require the file within the .module_load_path" do
      subject.load_module(name)

      expect($LOADED_FEATURES).to include(
        File.join(mock_lib_dir,subject.module_load_path,"#{name}.rb")
      )
    end

    it "must return the registered module" do
      expect(subject.load_module(name)).to be(mod)
    end

    it "must register the module with the same name as the file" do
      subject.load_module(name)

      expect(subject.module_registry[name]).to be(mod)
    end

    context "when the file does not exist" do
      let(:name) { 'does_not_exist' }

      it do
        expect {
          subject.load_module(name)
        }.to raise_error(described_class::ModuleNotFound,"could not load module #{name.inspect}")
      end
    end

    context "when the file does not register a module" do
      let(:name) { 'no_module' }
      let(:path) { File.join(subject.module_load_path,"#{name}") }

      it do
        expect {
          subject.load_module(name)
        }.to raise_error(described_class::ModuleNotFound,"module with name #{name.inspect} not found in file #{path.inspect}")
      end
    end

    context "when the file registers a module of a different name" do
      let(:name) { 'name_mismatch' }
      let(:path) { File.join(subject.module_load_path,"#{name}") }

      it do
        expect {
          subject.load_module(name)
        }.to raise_error(described_class::ModuleNotFound,"module with name #{name.inspect} not found in file #{path.inspect}")
      end
    end
  end

  after { $LOAD_PATH.delete(mock_lib_dir) }
end
