require 'spec_helper'
require 'ronin/core/params/types/regexp'

describe Ronin::Core::Params::Types::Regexp do
  describe "#coerce" do
    context "when given a Regexp value" do
      let(:value) { /foo/ }

      it "must return the Regexp" do
        expect(subject.coerce(value)).to eq(value)
      end
    end

    context "when given a String value" do
      context "and the String is of the format '/.../'" do
        let(:value) { "/foo/" }

        it "must parse the contents of the String as a Regexp" do
          expect(subject.coerce(value)).to eq(Regexp.new(value[1..-2]))
        end
      end

      context "but the String does not parse to a valid Regexp" do
        let(:value) { "/foo[/" }

        it do
          expect {
            subject.coerce(value)
          }.to raise_error(Ronin::Core::Params::ValidationError,"value is not a valid Regexp (#{value.inspect})")
        end
      end

      context "but the String does not start with a '/' character" do
        let(:value) { "foo/" }

        it do
          expect {
            subject.coerce(value)
          }.to raise_error(Ronin::Core::Params::ValidationError,"value must be of the format '/.../' (#{value.inspect})")
        end
      end

      context "but the String does not end with a '/' character" do
        let(:value) { "/foo" }

        it do
          expect {
            subject.coerce(value)
          }.to raise_error(Ronin::Core::Params::ValidationError,"value must be of the format '/.../' (#{value.inspect})")
        end
      end
    end

    context "when given a non-Regexp and non-String value" do
      let(:value) { Object.new }

      it do
        expect {
          subject.coerce(value)
        }.to raise_error(Ronin::Core::Params::ValidationError,"value must be either a String or a Regexp (#{value.inspect})")
      end
    end
  end
end
