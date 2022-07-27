require 'spec_helper'
require 'ronin/core/params/types/integer'

describe Ronin::Core::Params::Types::Integer do
  describe "#coerce" do
    context "when given an Integer" do
      let(:value) { 42 }

      it "must return the Integer value" do
        expect(subject.coerce(value)).to eq(value)
      end
    end

    context "when given a String" do
      context "and the String contains decimal digits" do
        let(:value) { "42" }

        it "must parse the String as base 10 and return an Integer" do
          expect(subject.coerce(value)).to eq(value.to_i)
        end

        context "and the String also starts with a '+'" do
          let(:value) { "+42" }

          it "must parse the String as base 10 and return an Integer" do
            expect(subject.coerce(value)).to eq(value.to_i)
          end
        end

        context "and the String also starts with a '-'" do
          let(:value) { "-42" }

          it "must parse the String as base 10 and return a negative Integer" do
            expect(subject.coerce(value)).to eq(-value[1..].to_i)
          end
        end
      end

      context "and the String contains hexadecimal digits" do
        let(:value) { "ff" }

        it "must parse the String as base 16 and return an Integer" do
          expect(subject.coerce(value)).to eq(value.to_i(16))
        end

        context "and the String also starts with a '+'" do
          let(:value) { "+ff" }

          it "must parse the String as base 16 and return an Integer" do
            expect(subject.coerce(value)).to eq(value.to_i(16))
          end
        end

        context "and the String also starts with a '-'" do
          let(:value) { "-ff" }

          it "must parse the String as base 16 and return a negative Integer" do
            expect(subject.coerce(value)).to eq(-value[1..].to_i(16))
          end
        end

        context "but the String also starts with '0x'" do
          let(:value) { "0xff" }

          it "must remove the leading '0x' before parsing the String" do
            expect(subject.coerce(value)).to eq(value[2..].to_i(16))
          end

          context "and the String also starts with a '+'" do
            let(:value) { "+0xff" }

            it "must parse the String as base 16 and return a Integer" do
              expect(subject.coerce(value)).to eq(value[3..].to_i(16))
            end
          end

          context "and the String also starts with a '-'" do
            let(:value) { "-0xff" }

            it "must parse the String as base 16 and return a negative Integer" do
              expect(subject.coerce(value)).to eq(-value[3..].to_i(16))
            end
          end
        end
      end

      context "and the String starts with '0b' and only contains chars 0 and 1" do
        let(:value) { "0b111" }

        it "must parse the String as binary and return an Integer" do
          expect(subject.coerce(value)).to eq(value[2..].to_i(2))
        end

        context "and the String also starts with a '+'" do
          let(:value) { "+0b111" }

          it "must parse the String as base 16 and return a Integer" do
            expect(subject.coerce(value)).to eq(value[3..].to_i(2))
          end
        end

        context "and the String also starts with a '-'" do
          let(:value) { "-0b111" }

          it "must parse the String as base 16 and return a negative Integer" do
            expect(subject.coerce(value)).to eq(-value[3..].to_i(2))
          end
        end
      end

      context "but the String contains non-numeric characters" do
        let(:value) { "bar" }

        it do
          expect {
            subject.coerce(value)
          }.to raise_error(Ronin::Core::Params::ValidationError,"value contains non-numeric characters (#{value.inspect})")
        end
      end
    end

    context "when given a non-Integer and non-String Object" do
      context "and it defines a #to_i method" do
        module TestTypesInteger
          class ObjectWithToI
            def to_i
              42
            end
          end
        end

        let(:value) { TestTypesInteger::ObjectWithToI.new }

        it "must call #to_i on the given value" do
          expect(subject.coerce(value)).to eq(value.to_i)
        end
      end

      context "but it does not define a #to_i method" do
        module TestTypesInteger
          class ObjectWithoutToI
          end
        end

        let(:value) { TestTypesInteger::ObjectWithoutToI.new }

        it do
          expect {
            subject.coerce(value)
          }.to raise_error(Ronin::Core::Params::ValidationError,"value does not define a #to_i method (#{value.inspect})")
        end
      end
    end
  end
end
