require 'spec_helper'
require 'ronin/core/metadata/module_name'

describe Ronin::Core::Metadata::ModuleName do
  describe ".module_name" do
    subject { test_class }

    context "and when module_name is not set in the class" do
      module TestMetadataModuleName
        class WithNoModuleNameSet
          include Ronin::Core::Metadata::ModuleName
        end
      end

      let(:test_class) { TestMetadataModuleName::WithNoModuleNameSet }

      it "must default to nil" do
        expect(subject.module_name).to be(nil)
      end
    end

    context "and when module_name is set in the class" do
      module TestMetadataModuleName
        class WithModuleNameSet
          include Ronin::Core::Metadata::ModuleName

          module_name 'test'
        end
      end

      let(:test_class) { TestMetadataModuleName::WithModuleNameSet }

      it "must return the set module_name" do
        expect(subject.module_name).to eq("test")
      end
    end

    context "but when the module_name was set in the superclass" do
      module TestMetadataModuleName
        class InheritsItsModuleName < WithModuleNameSet
          include Ronin::Core::Metadata::ModuleName
        end
      end

      let(:test_class) { TestMetadataModuleName::InheritsItsModuleName }

      it "must return nil" do
        expect(subject.module_name).to be(nil)
      end

      context "but the module_name is overridden in the sub-class" do
        module TestMetadataModuleName
          class OverridesItsInheritedModuleName < WithModuleNameSet
            include Ronin::Core::Metadata::ModuleName

            module_name "test2"
          end
        end

        let(:test_class) do
          TestMetadataModuleName::OverridesItsInheritedModuleName
        end

        it "must return the module_name set in the sub-class" do
          expect(subject.module_name).to eq("test2")
        end
      end
    end
  end
end
