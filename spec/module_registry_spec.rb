require 'spec_helper'
require 'ronin/core/module_registry'

describe Ronin::Core::ModuleRegistry do
  let(:fixtures_dir) { File.join(__dir__,'fixtures') }
  let(:modules_dir) { File.join(fixtures_dir,'modules') }

  describe ".modules_dir" do
    context "when a modules_dir has been defined" do
      module TestModuleRegistry
        module WithAModulesDir
          include Ronin::Core::ModuleRegistry

          modules_dir "#{__dir__}/test/dir"
        end
      end

      subject { TestModuleRegistry::WithAModulesDir }

      it "must return the previously set .modules_dir" do
        expect(subject.modules_dir).to eq("#{__dir__}/test/dir")
      end
    end

    context "but when no modules_dir has been defined" do
      module TestModuleRegistry
        module WithNoModuleLoadPath
          include Ronin::Core::ModuleRegistry
        end
      end

      subject { TestModuleRegistry::WithNoModuleLoadPath }

      it do
        expect {
          subject.modules_dir
        }.to raise_error(NotImplementedError,"#{subject} did not define a modules_dir")
      end
    end
  end

  module TestModuleRegistry
    module ExampleNamespace
      include Ronin::Core::ModuleRegistry
      modules_dir "#{__dir__}/fixtures/module_registry/modules"
    end
  end

  subject { TestModuleRegistry::ExampleNamespace }

  describe ".list_modules" do
    it "must return an Array of module names" do
      expect(subject.list_modules).to eq(
        %w[
          loaded_module
          name_mismatch
          no_module
        ]
      )
    end
  end

  describe ".module_registry" do
    it "must default to {}" do
      expect(subject.module_registry).to eq({})
    end
  end

  describe ".find_module" do
    context "when the module name exists within the .modules_dir" do
      let(:name) { 'loaded_module' }

      it "must return the path to the .rb file for the module" do
        expect(subject.find_module(name)).to eq(
          File.join(subject.modules_dir,"#{name}.rb")
        )
      end
    end

    context "when the module name does not have a file within .modules_dir" do
      let(:name) { "does_not_exist" }

      it "must return nil" do
        expect(subject.find_module(name)).to be(nil)
      end
    end
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

    it "must require the file within the .modules_dir" do
      subject.load_module(name)

      expect($LOADED_FEATURES).to include(
        File.join(subject.modules_dir,"#{name}.rb")
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
        }.to raise_error(described_class::ModuleNotFound,"could not find module #{name.inspect}")
      end
    end

    context "when the file does not register a module" do
      let(:name) { 'no_module' }
      let(:path) { File.join(subject.modules_dir,"#{name}.rb") }

      it do
        expect {
          subject.load_module(name)
        }.to raise_error(described_class::ModuleNotFound,"module with name #{name.inspect} not found in file #{path.inspect}")
      end
    end

    context "when the file registers a module of a different name" do
      let(:name) { 'name_mismatch' }
      let(:path) { File.join(subject.modules_dir,"#{name}.rb") }

      it do
        expect {
          subject.load_module(name)
        }.to raise_error(described_class::ModuleNotFound,"module with name #{name.inspect} not found in file #{path.inspect}")
      end
    end
  end

  after { $LOAD_PATH.delete(modules_dir) }
end
