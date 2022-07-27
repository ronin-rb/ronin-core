require 'spec_helper'
require 'ronin/core/params/types/uri'

describe Ronin::Core::Params::Types::URI do
  describe "#coerce" do
    context "when given a Regexp value" do
      let(:value) { URI('https://example.com/') }

      it "must return the Regexp" do
        expect(subject.coerce(value)).to eq(value)
      end
    end

    context "when given a String value" do
      let(:value) { "https://example.com/" }

      it "must parse the String as a URI" do
        expect(subject.coerce(value)).to eq(URI.parse(value))
      end

      context "but the String is empty" do
        let(:value) { "" }

        it do
          expect {
            subject.coerce(value)
          }.to raise_error(Ronin::Core::Params::ValidationError,"value must not be empty")
        end
      end

      context "but the String does not start with a 'scheme:'" do
        let(:value) { "foo" }

        it do
          expect {
            subject.coerce(value)
          }.to raise_error(Ronin::Core::Params::ValidationError,"value must start with a 'scheme:' (#{value.inspect})")
        end
      end

      context "but the String cannot be parsed as a valid URI" do
        let(:value) { "https:// \n" }

        it do
          expect {
            subject.coerce(value)
          }.to raise_error(Ronin::Core::Params::ValidationError,"value is not a valid URI (#{value.inspect})")
        end
      end
    end

    context "when given a non-URI and non-String value" do
      let(:value) { Object.new }

      it do
        expect {
          subject.coerce(value)
        }.to raise_error(Ronin::Core::Params::ValidationError,"value must be either a String or a URI (#{value.inspect})")
      end
    end
  end
end
