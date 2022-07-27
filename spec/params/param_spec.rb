require 'spec_helper'
require 'ronin/core/params/param'
require 'ronin/core/params/types/integer'

describe Ronin::Core::Params::Param do
  let(:name) { :foo }
  let(:type) { Ronin::Core::Params::Types::Integer.new }
  let(:desc) { "Foo param" }

  subject { described_class.new(name,type, desc: desc) }

  describe "#initialize" do
    it "must set #name" do
      expect(subject.name).to eq(name)
    end

    it "must set #type" do
      expect(subject.type).to eq(type)
    end

    it "must set #desc" do
      expect(subject.desc).to eq(desc)
    end

    it "must require the desc: keyword argument" do
      expect {
        described_class.new(name,type)
      }.to raise_error(ArgumentError)
    end

    it "must default #required to false" do
      expect(subject.required).to be(false)
    end

    it "must default #default to nil" do
      expect(subject.default).to be(nil)
    end

    context "when given the required: keyword argument" do
      subject { described_class.new(name,type, required: true, desc: desc) }

      it "must set #required" do
        expect(subject.required).to be(true)
      end
    end

    context "when given the default: keyword argument" do
      let(:default) { 42 }

      subject { described_class.new(name,type, default: default, desc: desc) }

      it "must set #default" do
        expect(subject.default).to eq(default)
      end
    end
  end

  describe "#required?" do
    context "when initialized with no required: keyword argument" do
      subject { described_class.new(name,type, desc: desc) }

      it "must return false" do
        expect(subject.required?).to be(false)
      end
    end

    context "when initialized with required: true" do
      subject { described_class.new(name,type, required: true, desc: desc) }

      it "must return true" do
        expect(subject.required?).to be(true)
      end
    end

    context "when initialized with required: false" do
      subject { described_class.new(name,type, required: false, desc: desc) }

      it "must return false" do
        expect(subject.required?).to be(false)
      end
    end
  end

  describe "#has_default?" do
    context "when initialized with no default: keyword argument" do
      subject { described_class.new(name,type, desc: desc) }

      it "must return false" do
        expect(subject.has_default?).to be(false)
      end
    end

    context "when initialized with the default: keyword argument" do
      subject { described_class.new(name,type, default: 42, desc: desc) }

      it "must return true" do
        expect(subject.has_default?).to be(true)
      end
    end
  end

  describe "#default_value" do
    context "when initialized with no default: keyword argument" do
      subject { described_class.new(name,type, desc: desc) }

      it "must return nil" do
        expect(subject.default_value).to be(nil)
      end
    end

    context "when initialized with the default: keyword argument" do
      context "and it's an Object" do
        let(:default) { 'value' }

        subject { described_class.new(name,type, default: default, desc: desc) }

        it "must return a new copy of the default value" do
          expect(subject.default_value).to eq(default)
          expect(subject.default_value).to_not be(default)
        end
      end

      context "and it's a Proc" do
        let(:default) do
          proc { "value" }
        end

        subject { described_class.new(name,type, default: default, desc: desc) }

        it "must call the Proc and return the value" do
          expect(subject.default_value).to eq(default.call)
        end
      end
    end
  end

  describe "#coerce" do
    let(:value) { '42' }

    context "when given nil" do
      context "and when initialize with required: true" do
        subject { described_class.new(name,type, required: true, desc: desc) }

        it do
          expect {
            subject.coerce(nil)
          }.to raise_error(Ronin::Core::Params::ValidationError,"param requires a non-nil value")
        end
      end

      context "and when is not initialize with required: true" do
        it "must return nil" do
          expect(subject.coerce(nil)).to be(nil)
        end
      end
    end

    context "when given a non-nil value" do
      it "must coerce the value using #type" do
        expect(subject.coerce(value)).to eq(type.coerce(value))
      end
    end
  end
end
