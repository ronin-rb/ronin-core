require 'spec_helper'
require 'ronin/core/metadata/id'

describe Ronin::Core::Metadata::ID do
  module TestMetadataID
    class WithNoIDSet
      include Ronin::Core::Metadata::ID
    end

    class WithIDSet
      include Ronin::Core::Metadata::ID

      id 'test'
    end
  end

  describe ".id" do
    subject { test_class }

    context "and when id is not set in the class" do
      let(:test_class) { TestMetadataID::WithNoIDSet }

      it "must default to nil" do
        expect(subject.id).to be(nil)
      end
    end

    context "and when id is set in the class" do
      let(:test_class) { TestMetadataID::WithIDSet }

      it "must return the set id" do
        expect(subject.id).to eq("test")
      end
    end

    context "but when the id was set in the superclass" do
      module TestMetadataID
        class InheritsItsID < WithIDSet
          include Ronin::Core::Metadata::ID
        end
      end

      let(:test_class) { TestMetadataID::InheritsItsID }

      it "must return nil" do
        expect(subject.id).to be(nil)
      end

      context "but the id is overridden in the sub-class" do
        module TestMetadataID
          class OverridesItsInheritedID < WithIDSet
            include Ronin::Core::Metadata::ID

            id "test2"
          end
        end

        let(:test_class) do
          TestMetadataID::OverridesItsInheritedID
        end

        it "must return the id set in the sub-class" do
          expect(subject.id).to eq("test2")
        end

        it "must not modify the superclass'es id" do
          expect(subject.superclass.id).to eq('test')
        end
      end
    end
  end

  describe "#class_id" do
    subject { test_class.new }

    context "when the class'es .id is not set" do
      let(:test_class) { TestMetadataID::WithNoIDSet }

      it "must return nil" do
        expect(subject.class_id).to be(nil)
      end
    end

    context "when the class'es .id is set" do
      let(:test_class) { TestMetadataID::WithIDSet }

      it "must return the .id" do
        expect(subject.class_id).to eq(test_class.id)
      end
    end
  end
end
