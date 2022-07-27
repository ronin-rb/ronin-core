require 'spec_helper'
require 'ronin/core/params/types/numeric'

describe Ronin::Core::Params::Types::Numeric do
  describe "#initialize" do
    it "must default #min to nil" do
      expect(subject.min).to be(nil)
    end

    it "must default #max to nil" do
      expect(subject.max).to be(nil)
    end

    it "must default #range to nil" do
      expect(subject.range).to be(nil)
    end

    context "when given the min: keyword argument" do
      let(:min) { 42 }

      subject { described_class.new(min: min) }

      it "must set #min" do
        expect(subject.min).to eq(min)
      end
    end

    context "when given the max: keyword argument" do
      let(:max) { 42 }

      subject { described_class.new(max: max) }

      it "must set #max" do
        expect(subject.max).to eq(max)
      end
    end

    context "when given the range: keyword argument" do
      let(:range) { 1..42 }

      subject { described_class.new(range: range) }

      it "must set #range" do
        expect(subject.range).to eq(range)
      end
    end
  end

  describe "#coerce" do
    context "when #range is set" do
      let(:range) { 1..10 }

      subject { described_class.new(range: range) }

      context "and when the given number is within the range" do
        let(:value) { 5 }

        it "must return the number" do
          expect(subject.coerce(value)).to eq(value)
        end
      end

      context "but the given number is not within the range" do
        let(:value) { 20 }

        it do
          expect {
            subject.coerce(value)
          }.to raise_error(Ronin::Core::Params::ValidationError,"value is not within the range of acceptable values #{range.begin}-#{range.end} (#{value.inspect})")
        end
      end
    end

    context "when #min is set" do
      let(:min) { 10 }

      subject { described_class.new(min: min) }

      context "and when then value is above the #min value" do
        let(:value) { 20 }

        it "must return the value" do
          expect(subject.coerce(value)).to eq(value)
        end
      end

      context "and when then value is equal to the #min value" do
        let(:value) { min }

        it "must return the value" do
          expect(subject.coerce(value)).to eq(value)
        end
      end

      context "but when the value is below the #min value" do
        let(:value) { 5 }

        it do
          expect {
            subject.coerce(value)
          }.to raise_error(Ronin::Core::Params::ValidationError,"value is below minimum value of #{min} (#{value.inspect})")
        end
      end
    end

    context "when #max is set" do
      let(:max) { 10 }

      subject { described_class.new(max: max) }

      context "and when then value is below the #max value" do
        let(:value) { 5 }

        it "must return the value" do
          expect(subject.coerce(value)).to eq(value)
        end
      end

      context "and when then value is equal to the #max value" do
        let(:value) { max }

        it "must return the value" do
          expect(subject.coerce(value)).to eq(value)
        end
      end

      context "but when the value is above the #max value" do
        let(:value) { 20 }

        it do
          expect {
            subject.coerce(value)
          }.to raise_error(Ronin::Core::Params::ValidationError,"value is above maximum value of #{max} (#{value.inspect})")
        end
      end
    end
  end
end
