require 'spec_helper'
require 'ronin/core/metadata/summary'

describe Ronin::Core::Metadata::Summary do
  describe ".summary" do
    subject { test_class }

    context "and when summary is not set in the class" do
      module TestMetadataSummary
        class WithNoSummarySet
          include Ronin::Core::Metadata::Summary
        end
      end

      let(:test_class) { TestMetadataSummary::WithNoSummarySet }

      it "must default to nil" do
        expect(subject.summary).to be(nil)
      end
    end

    context "and when summary is set in the class" do
      module TestMetadataSummary
        class WithSummarySet
          include Ronin::Core::Metadata::Summary

          summary 'test'
        end
      end

      let(:test_class) { TestMetadataSummary::WithSummarySet }

      it "must return the set summary" do
        expect(subject.summary).to eq("test")
      end
    end

    context "but when the summary was set in the superclass" do
      module TestMetadataSummary
        class InheritsItsSummary < WithSummarySet
          include Ronin::Core::Metadata::Summary
        end
      end

      let(:test_class) { TestMetadataSummary::InheritsItsSummary }

      it "must return the summary set in the superclass" do
        expect(subject.summary).to eq("test")
      end

      context "but the summary is overridden in the sub-class" do
        module TestMetadataSummary
          class OverridesItsInheritedSummary < WithSummarySet
            include Ronin::Core::Metadata::Summary

            summary "test2"
          end
        end

        let(:test_class) do
          TestMetadataSummary::OverridesItsInheritedSummary
        end

        it "must return the summary set in the sub-class" do
          expect(subject.summary).to eq("test2")
        end

        it "must not modify the superclass'es summary" do
          expect(subject.superclass.summary).to eq('test')
        end
      end
    end
  end
end
