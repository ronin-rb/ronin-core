require 'spec_helper'
require 'ronin/core/params/types/enum'

describe Ronin::Core::Params::Types::Enum do
  let(:values) { [:one, :two, :three] }

  subject { described_class.new(values) }

  describe "#initialize" do
    it "must set #values" do
      expect(subject.values).to eq(values)
    end

    context "when given an empty Array" do
      it do
        expect {
          described_class.new([])
        }.to raise_error(ArgumentError,"cannot initialize an empty Enum")
      end
    end
  end

  describe ".[]" do
    subject { described_class[*values] }

    it "must return a new #{described_class}" do
      expect(subject).to be_kind_of(described_class)
    end

    it "must set #values to the given arguments" do
      expect(subject.values).to eq(values)
    end

    context "when given no arguments" do
      it do
        expect {
          described_class[]
        }.to raise_error(ArgumentError,"cannot initialize an empty Enum")
      end
    end
  end

  describe "#coerce" do
    context "when givne a Symbol" do
      context "and when the Symbol is in #values" do
        let(:value) { values[1] }

        it "must return that Symbol" do
          expect(subject.coerce(value)).to eq(value)
        end
      end

      context "but the Symbol is not within #values" do
        let(:value) { :foo }

        it do
          expect {
            subject.coerce(value)
          }.to raise_error(Ronin::Core::Params::ValidationError,"unknown value (#{value.inspect})")
        end
      end
    end

    context "when given a String" do
      context "and it maps to one of the Symbols in #values" do
        let(:value) { values[1].to_s }

        it "must return the Symbol version of the String" do
          expect(subject.coerce(value)).to eq(values[1])
        end
      end

      context "but it does not map to any of the Symbols in #values" do
        let(:value) { "foo" }

        it "must return the Symbol version of the String" do
          expect {
            subject.coerce(value)
          }.to raise_error(Ronin::Core::Params::ValidationError,"unknown value (#{value.inspect})")
        end
      end
    end

    context "when given a non-Symbol and non-String object" do
      let(:value) { Object.new }

      it do
        expect {
          subject.coerce(value)
        }.to raise_error(Ronin::Core::Params::ValidationError,"value must be either a Symbol or a String (#{value.inspect})")
      end
    end
  end
end
