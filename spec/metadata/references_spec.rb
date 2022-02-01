require 'spec_helper'
require 'ronin/core/metadata/references'

describe Ronin::Core::Metadata::References do
  describe ".references" do
    subject { test_class }

    context "and when references is not set in the shell class" do
      module TestMetadataReferences
        class WithNoReferencesSet
          include Ronin::Core::Metadata::References
        end
      end

      let(:test_class) { TestMetadataReferences::WithNoReferencesSet }

      it "must default to []" do
        expect(subject.references).to eq([])
      end
    end

    context "and when references is set in the shell class" do
      module TestMetadataReferences
        class WithReferencesSet
          include Ronin::Core::Metadata::References

          references [
            'https://example.com/link1',
            'https://example.com/link2'
          ]
        end
      end

      let(:test_class) { TestMetadataReferences::WithReferencesSet }

      it "must return the set references" do
        expect(subject.references).to eq(
          [
            'https://example.com/link1',
            'https://example.com/link2'
          ]
        )
      end
    end

    context "but when the references was set in the superclass" do
      module TestMetadataReferences
        class InheritsItsReferences < WithReferencesSet
          include Ronin::Core::Metadata::References
        end
      end

      let(:test_class) { TestMetadataReferences::InheritsItsReferences }

      it "must return the references set in the superclass" do
        expect(subject.references).to eq(
          [
            'https://example.com/link1',
            'https://example.com/link2'
          ]
        )
      end

      context "but the references is overridden in the sub-class" do
        module TestMetadataReferences
          class OverridesItsInheritedReferences < WithReferencesSet
            include Ronin::Core::Metadata::References

            references [
              'https://example.com/link3'
            ]
          end
        end

        let(:test_class) do
          TestMetadataReferences::OverridesItsInheritedReferences
        end

        it "must return the references in the sub-class and the superclass" do
          expect(subject.references).to eq(
            [
              'https://example.com/link1',
              'https://example.com/link2',
              'https://example.com/link3'
            ]
          )
        end
      end
    end
  end
end
