require 'spec_helper'
require 'ronin/core/output_formats/output_format'

require 'stringio'

describe Ronin::Core::OutputFormats::OutputFormat do
  describe "#<<" do
    it do
      expect {
        subject << [1,2,3]
      }.to raise_error(NotImplementedError,"#{described_class}#<< was not implemented")
    end
  end
end
