require 'spec_helper'
require 'ronin/core/params/types/float'

describe Ronin::Core::Params::Types::Float do
  describe "#coerce" do
    context "when given a Float" do
      let(:value) { 0.5 }

      it "must return the Float value" do
        expect(subject.coerce(value)).to be(value)
      end
    end

    context "when given a String" do
      context "and it is in the format of a decimal number" do
        let(:value) { '0.5' }

        it "must parse the String as a Float" do
          expect(subject.coerce(value)).to eq(value.to_f)
        end

        context "but it starts with a '+'" do
          let(:value) { '+0.5' }

          it "must parse the String as a Float" do
            expect(subject.coerce(value)).to eq(value[1..].to_f)
          end
        end

        context "but it starts with a '-'" do
          let(:value) { '-0.5' }

          it "must parse the String as a negative Float" do
            expect(subject.coerce(value)).to eq(-value[1..].to_f)
          end
        end
      end

      context "and it is in the fomrat of a whole number" do
        let(:value) { '1' }

        it "must parse the String as a Float" do
          expect(subject.coerce(value)).to eq(value.to_f)
        end

        context "but it starts with a '+'" do
          let(:value) { '+1' }

          it "must parse the String as a Float" do
            expect(subject.coerce(value)).to eq(value[1..].to_f)
          end
        end

        context "but it starts with a '-'" do
          let(:value) { '-1' }

          it "must parse the String as a negative Float" do
            expect(subject.coerce(value)).to eq(-value[1..].to_f)
          end
        end
      end

      context "but it contains non-numeric characters" do
        let(:value) { "foo" }

        it do
          expect {
            subject.coerce(value)
          }.to raise_error(Ronin::Core::Params::ValidationError,"value contains non-numeric characters (#{value.inspect})")
        end
      end
    end

    context "when given a non-Float and non-String object" do
      context "and it defines a #to_f method" do
        module TestTypesFloat
          class ObjectWithToF
            def to_f
              0.5
            end
          end
        end

        let(:value) { TestTypesFloat::ObjectWithToF.new }

        it "must call the #to_f method on the value" do
          expect(subject.coerce(value)).to eq(value.to_f)
        end
      end

      context "but it does not define a #to_f method" do
        module TestTypesFloat
          class ObjectWithoutToF
          end
        end

        let(:value) { TestTypesFloat::ObjectWithoutToF.new }

        it do
          expect {
            subject.coerce(value)
          }.to raise_error(Ronin::Core::Params::ValidationError,"value does not define a #to_f method (#{value.inspect})")
        end
      end
    end
  end
end
