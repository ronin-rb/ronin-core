require 'spec_helper'
require 'ronin/core/metadata/description'

describe Ronin::Core::Metadata::Description do
  describe ".description" do
    subject { test_class }

    context "and when description is not set in the class" do
      module TestMetadataDescription
        class WithNoDescriptionSet
          include Ronin::Core::Metadata::Description
        end
      end

      let(:test_class) { TestMetadataDescription::WithNoDescriptionSet }

      it "must default to nil" do
        expect(subject.description).to be(nil)
      end
    end

    context "and when description is set in the class" do
      module TestMetadataDescription
        class WithDescriptionSet
          include Ronin::Core::Metadata::Description

          description 'test'
        end
      end

      let(:test_class) { TestMetadataDescription::WithDescriptionSet }

      it "must return the set description" do
        expect(subject.description).to eq("test")
      end
    end

    context "but when the description was set in the superclass" do
      module TestMetadataDescription
        class InheritsItsDescription < WithDescriptionSet
          include Ronin::Core::Metadata::Description
        end
      end

      let(:test_class) { TestMetadataDescription::InheritsItsDescription }

      it "must return the description set in the superclass" do
        expect(subject.description).to eq("test")
      end

      context "but the description is overridden in the sub-class" do
        module TestMetadataDescription
          class OverridesItsInheritedDescription < WithDescriptionSet
            include Ronin::Core::Metadata::Description

            description "test2"
          end
        end

        let(:test_class) do
          TestMetadataDescription::OverridesItsInheritedDescription
        end

        it "must return the description set in the sub-class" do
          expect(subject.description).to eq("test2")
        end

        it "must not modify the superclass'es description" do
          expect(subject.superclass.description).to eq('test')
        end
      end
    end
  end
end
