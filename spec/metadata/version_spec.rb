require 'spec_helper'
require 'ronin/core/metadata/version'

describe Ronin::Core::Metadata::Version do
  module TestMetadataVersion
    class WithNoVersionSet
      include Ronin::Core::Metadata::Version
    end

    class WithVersionSet
      include Ronin::Core::Metadata::Version

      version '0.1'
    end
  end

  describe ".version" do
    subject { test_class }

    context "and when version is not set in the class" do
      let(:test_class) { TestMetadataVersion::WithNoVersionSet }

      it "must default to nil" do
        expect(subject.version).to be(nil)
      end
    end

    context "and when version is set in the class" do
      let(:test_class) { TestMetadataVersion::WithVersionSet }

      it "must return the set version" do
        expect(subject.version).to eq("0.1")
      end
    end

    context "but when the version was set in the superclass" do
      module TestMetadataVersion
        class InheritsItsVersion < WithVersionSet
          include Ronin::Core::Metadata::Version
        end
      end

      let(:test_class) { TestMetadataVersion::InheritsItsVersion }

      it "must return nil" do
        expect(subject.version).to be(nil)
      end

      context "but the version is overrversionden in the sub-class" do
        module TestMetadataVersion
          class OverrversionesItsInheritedVersion < WithVersionSet
            include Ronin::Core::Metadata::Version

            version '0.2'
          end
        end

        let(:test_class) do
          TestMetadataVersion::OverrversionesItsInheritedVersion
        end

        it "must return the version set in the sub-class" do
          expect(subject.version).to eq("0.2")
        end

        it "must not modify the superclass'es version" do
          expect(subject.superclass.version).to eq('0.1')
        end
      end
    end
  end
end
