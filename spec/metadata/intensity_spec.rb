require 'spec_helper'
require 'ronin/core/metadata/intensity'

describe Ronin::Core::Metadata::Intensity do
  describe ".intensity" do
    subject { test_class }

    context "and when intensity is not set in the class" do
      module TestMetadataIntensity
        class WithNoIntencitySet
          include Ronin::Core::Metadata::Intensity
        end
      end

      let(:test_class) { TestMetadataIntensity::WithNoIntencitySet }

      it "must default to :active" do
        expect(subject.intensity).to eq(:active)
      end
    end

    context "and when intensity is set in the class" do
      module TestMetadataIntensity
        class WithIntensitySet
          include Ronin::Core::Metadata::Intensity

          intensity :passive
        end
      end

      let(:test_class) { TestMetadataIntensity::WithIntensitySet }

      it "must return the set intensity" do
        expect(subject.intensity).to eq(:passive)
      end
    end

    context "but when the intensity was set in the superclass" do
      module TestMetadataIntensity
        class InheritsItsIntensity < WithIntensitySet
          include Ronin::Core::Metadata::Intensity
        end
      end

      let(:test_class) { TestMetadataIntensity::InheritsItsIntensity }

      it "must return the intensity set in the superclass" do
        expect(subject.intensity).to eq(:passive)
      end

      context "but the intensity is overridden in the sub-class" do
        module TestMetadataIntensity
          class OverridesItsInheritedIntensity < WithIntensitySet
            include Ronin::Core::Metadata::Intensity

            intensity :aggressive
          end
        end

        let(:test_class) do
          TestMetadataIntensity::OverridesItsInheritedIntensity
        end

        it "must return the intensity in the sub-class and the superclass" do
          expect(subject.intensity).to eq(:aggressive)
        end

        it "must not modify the superclass'es intensity" do
          expect(subject.superclass.intensity).to eq(:passive)
        end
      end
    end
  end
end
