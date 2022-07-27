require 'spec_helper'
require 'ronin/core/params/types/boolean'

describe Ronin::Core::Params::Types::Boolean do
  describe "#coerce" do
    context "when given true" do
      it "must return true" do
        expect(subject.coerce(true)).to be(true)
      end
    end

    context "when given false" do
      it "must return false" do
        expect(subject.coerce(false)).to be(false)
      end
    end

    context "when given a String" do
      %w[true True TRUE yes Yes YES y Y on On ON].each do |value|
        context "and it's #{value.inspect}" do
          it "must return true" do
            expect(subject.coerce(value)).to be(true)
          end
        end
      end

      %w[false False FALSE no No NO n N off Off OFF].each do |value|
        context "and it's #{value.inspect}" do
          it "must return false" do
            expect(subject.coerce(value)).to be(false)
          end
        end
      end

      context "when given an unrecognized String" do
        let(:value) { "foo" }

        it do
          expect {
            subject.coerce(value)
          }.to raise_error(Ronin::Core::Params::ValidationError,"value must be either 'true', 'false', 'yes', 'no', 'y', 'n', 'on', or 'off' (#{value.inspect})")
        end
      end
    end

    context "when given a non-Boolean and non-String object" do
      let(:value) { Object.new }

      it do
        expect {
          subject.coerce(value)
        }.to raise_error(Ronin::Core::Params::ValidationError,"value must be either true, false, or a String (#{value.inspect})")
      end
    end
  end
end
