require 'spec_helper'
require 'ronin/core/params/types/type'

describe Ronin::Core::Params::Types::Type do
  describe "#corece" do
    let(:value) { Object.new }

    it do
      expect {
        subject.coerce(value)
      }.to raise_error(NotImplementedError,"#{described_class}#coerce method was not implemented")
    end
  end
end
