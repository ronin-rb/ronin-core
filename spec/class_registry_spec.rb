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
          loaded_class
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
      let(:id) { 'loaded_class' }

      it "must return the path to the .rb file for the module" do
        expect(subject.path_for(id)).to eq(
          File.join(subject.class_dir,"#{id}.rb")
        )
      end
    end

    context "when the module name does not have a file within .class_dir" do
      let(:id) { "does_not_exist" }

      it "must return nil" do
        expect(subject.path_for(id)).to be(nil)
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

    let(:id)    { 'foo' }
    let(:klass) { TestClassRegistry::ExampleNamespace::Foo }

    before { subject.register(id,klass) }

    it "must add the class id and class to #registry" do
      expect(subject.registry[id]).to be(klass)
    end

    after { subject.registry.clear }
  end

  describe ".load_class_from_file" do
    let(:id)    { 'loaded_class' }
    let(:file)  { File.join(subject.class_dir,"#{id}.rb") }
    let(:klass) { ExampleClassRegistry::LoadedClass }

    it "must load the file" do
      expect(subject).to receive(:load).with(file) do
        load(file)
      end

      subject.load_class_from_file(file)
    end

    it "must return the registered module" do
      expect(subject.load_class_from_file(file)).to be(klass)
    end

    it "must register the module with the same id as the file" do
      subject.load_class_from_file(file)

      expect(subject.registry[id]).to be(klass)
    end

    context "when given a relative path" do
      let(:relative_path) { File.join(subject.class_dir,'foo','..',"#{id}.rb") }
      let(:absolute_path) { File.expand_path(relative_path) }

      it "must expand the path first" do
        expect(subject).to receive(:load).with(absolute_path) do
          load(absolute_path)
        end

        subject.load_class_from_file(relative_path)
      end
    end

    context "when the file does not exist" do
      let(:file)          { "path/does/not/exist.rb" }
      let(:absolute_path) { File.expand_path(file)   }

      it do
        expect {
          subject.load_class_from_file(file)
        }.to raise_error(described_class::ClassNotFound,"no such file or directory: #{absolute_path.inspect}")
      end
    end

    context "when the file does not register a module" do
      let(:id)   { 'no_module' }
      let(:file) { File.join(subject.class_dir,"#{id}.rb") }

      it do
        expect {
          subject.load_class_from_file(file)
        }.to raise_error(described_class::ClassNotFound,"file did not register a class: #{file.inspect}")
      end
    end

    after do
      subject.registry.clear
    end
  end

  describe ".load_class" do
    let(:id)    { 'loaded_class' }
    let(:klass) { ExampleClassRegistry::LoadedClass }
    let(:path)  { File.join(subject.class_dir,"#{id}.rb") }

    it "must require the file within the .class_dir" do
      subject.load_class(id)

      expect($LOADED_FEATURES).to include(path)
    end

    it "must return the registered module" do
      expect(subject.load_class(id)).to be(klass)
    end

    it "must register the module with the same id as the file" do
      subject.load_class(id)

      expect(subject.registry[id]).to be(klass)
    end

    context "when the file does not exist" do
      let(:id) { 'does_not_exist' }

      it do
        expect {
          subject.load_class(id)
        }.to raise_error(described_class::ClassNotFound,"could not find file for #{id.inspect}")
      end
    end

    context "when the file does not register a module" do
      let(:id) { 'no_module' }

      it do
        expect {
          subject.load_class(id)
        }.to raise_error(described_class::ClassNotFound,"file did not register a class: #{path.inspect}")
      end
    end

    context "when the file registers a module of a different name" do
      let(:id)            { 'name_mismatch' }
      let(:unexpected_id) { 'different_name' }

      it do
        expect {
          subject.load_class(id)
        }.to raise_error(described_class::ClassNotFound,"file registered a class with a different id (#{unexpected_id.inspect}): #{path.inspect}")
      end
    end

    after do
      subject.registry.clear
      $LOADED_FEATURES.delete(path)
    end
  end
end
