require 'spec_helper'
require 'ronin/core/params/types/string'

describe Ronin::Core::Params::Types::String do
  describe "#initialize" do
    it "must default #allow_empty? to false" do
      expect(subject.allow_empty?).to be(false)
    end

    it "must default #allow_blank? to false" do
      expect(subject.allow_blank?).to be(false)
    end

    it "must default #format to nil" do
      expect(subject.format).to be(nil)
    end

    context "when given the format: keyword argument" do
      let(:format) { /foo/ }

      subject { described_class.new(format: format) }

      it "must set #format" do
        expect(subject.format).to eq(format)
      end
    end
  end

  describe "#allow_empty?" do
    context "when initialized with allow_empty: true" do
      subject { described_class.new(allow_empty: true) }

      it "must return true" do
        expect(subject.allow_empty?).to be(true)
      end
    end

    context "when initialized with allow_empty: false" do
      subject { described_class.new(allow_empty: false) }

      it "must return false" do
        expect(subject.allow_empty?).to be(false)
      end
    end
  end

  describe "#allow_blank?" do
    context "when initialized with allow_blank: true" do
      subject { described_class.new(allow_blank: true) }

      it "must return true" do
        expect(subject.allow_blank?).to be(true)
      end
    end

    context "when initialized with allow_blank: false" do
      subject { described_class.new(allow_blank: false) }

      it "must return false" do
        expect(subject.allow_blank?).to be(false)
      end
    end
  end

  describe "#coerce" do
    context "when given an Enumerable" do
      let(:value) { ["foo", "bar"] }

      it do
        expect {
          subject.coerce(value)
        }.to raise_error(Ronin::Core::Params::ValidationError,"cannot convert an Enumerable into a String (#{value.inspect})")
      end
    end

    context "when given a String" do
      let(:value) { "foo" }

      it "must return the String" do
        expect(subject.coerce(value)).to eq(value)
      end

      context "but when #format is set" do
        subject { described_class.new(format: /foo/) }

        context "and the given value matches #format" do
          it "must return the String value" do
            expect(subject.coerce(value)).to eq(value)
          end
        end

        context "but the given value does not match #format" do
          let(:value) { "bar" }

          it do
            expect {
              subject.coerce(value)
            }.to raise_error(Ronin::Core::Params::ValidationError,"does not match the format (#{value.inspect})")
          end
        end
      end

      context "but the string is empty" do
        let(:value) { "" }

        it do
          expect {
            subject.coerce(value)
          }.to raise_error(Ronin::Core::Params::ValidationError,"value cannot be empty")
        end

        context "and when initialized with allow_empty: true" do
          subject { described_class.new(allow_empty: true) }

          it "must return the empty String" do
            expect(subject.coerce(value)).to eq(value)
          end
        end
      end

      context "but the String is all whitespace" do
        let(:value) { " \t\n\r" }

        it do
          expect {
            subject.coerce(value)
          }.to raise_error(Ronin::Core::Params::ValidationError,"value cannot contain all whitespace (#{value.inspect})")
        end

        context "and when initialized with allow_blank: true" do
          subject { described_class.new(allow_blank: true) }

          it "must return the blank String" do
            expect(subject.coerce(value)).to eq(value)
          end
        end
      end
    end

    context "when given a non-String object" do
      context "and it defines a #to_s method" do
        module TestTypesString
          class ObjectWithToS
            def to_s
              "foo"
            end
          end
        end

        let(:value) { TestTypesString::ObjectWithToS.new }

        it "must call #to_s on the value" do
          expect(subject.coerce(value)).to eq(value.to_s)
        end
      end

      context "but it does not respond to #to_s" do
        module TestTypesString
          class ObjectWithoutToS
            undef to_s
          end
        end

        let(:value) { TestTypesString::ObjectWithoutToS.new }

        it do
          expect {
            subject.coerce(value)
          }.to raise_error(Ronin::Core::Params::ValidationError,"value does not define a #to_s method (#{value.inspect})")
        end
      end
    end
  end
end
