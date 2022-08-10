require 'spec_helper'
require 'ronin/core/class_registry'

require 'fixtures/example_class_registry'

describe Ronin::Core::ClassRegistry do
  let(:fixtures_dir) { File.join(__dir__,'fixtures') }

  describe ".class_dir" do
    context "when a class_dir has been defined" do
      module TestClassRegistry
        module WithAModulesDir
          include Ronin::Core::ClassRegistry

          class_dir "#{__dir__}/test/dir"
        end
      end

      subject { TestClassRegistry::WithAModulesDir }

      it "must return the previously set .class_dir" do
        expect(subject.class_dir).to eq("#{__dir__}/test/dir")
      end
    end

    context "but when no class_dir has been defined" do
      module TestClassRegistry
        module WithNoModuleLoadPath
          include Ronin::Core::ClassRegistry
        end
      end

      subject { TestClassRegistry::WithNoModuleLoadPath }

      it do
        expect {
          subject.class_dir
        }.to raise_error(NotImplementedError,"#{subject} did not define a class_dir")
      end
    end
  end

  subject { ExampleClassRegistry }

  describe ".list_files" do
    it "must return an Array of module names" do
      expect(subject.list_files).to eq(
        %w[
          loaded_module
          name_mismatch
          no_module
        ]
      )
    end
  end

  describe ".registry" do
    it "must default to {}" do
      expect(subject.registry).to eq({})
    end
  end

  describe ".path_for" do
    context "when the module name exists within the .class_dir" do
      let(:name) { 'loaded_module' }

      it "must return the path to the .rb file for the module" do
        expect(subject.path_for(name)).to eq(
          File.join(subject.class_dir,"#{name}.rb")
        )
      end
    end

    context "when the module name does not have a file within .class_dir" do
      let(:name) { "does_not_exist" }

      it "must return nil" do
        expect(subject.path_for(name)).to be(nil)
      end
    end
  end

  describe ".register" do
    module TestClassRegistry
      module ExampleNamespace
        class Foo
        end
      end
    end

    let(:name) { 'foo' }
    let(:mod)  { TestClassRegistry::ExampleNamespace::Foo }

    before { subject.register(name,mod) }

    it "must add the module name and module to #registry" do
      expect(subject.registry[name]).to be(mod)
    end

    after { subject.registry.clear }
  end

  describe ".load_class" do
    let(:name) { 'loaded_module' }
    let(:mod)  { ExampleClassRegistry::LoadedModule }

    it "must require the file within the .class_dir" do
      subject.load_class(name)

      expect($LOADED_FEATURES).to include(
        File.join(subject.class_dir,"#{name}.rb")
      )
    end

    it "must return the registered module" do
      expect(subject.load_class(name)).to be(mod)
    end

    it "must register the module with the same name as the file" do
      subject.load_class(name)

      expect(subject.registry[name]).to be(mod)
    end

    context "when the file does not exist" do
      let(:name) { 'does_not_exist' }

      it do
        expect {
          subject.load_class(name)
        }.to raise_error(described_class::ClassNotFound,"could not find file #{name.inspect}")
      end
    end

    context "when the file does not register a module" do
      let(:name) { 'no_module' }
      let(:path) { File.join(subject.class_dir,"#{name}.rb") }

      it do
        expect {
          subject.load_class(name)
        }.to raise_error(described_class::ClassNotFound,"file did not register a class: #{path.inspect}")
      end
    end

    context "when the file registers a module of a different name" do
      let(:name) { 'name_mismatch' }
      let(:path) { File.join(subject.class_dir,"#{name}.rb") }

      let(:unexpected_name) { 'different_name' }

      it do
        expect {
          subject.load_class(name)
        }.to raise_error(described_class::ClassNotFound,"file registered a class with a different name (#{unexpected_name.inspect}): #{path.inspect}")
      end
    end
  end
end
