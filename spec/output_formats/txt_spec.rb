require 'spec_helper'
require 'ronin/core/output_formats/txt'

describe Ronin::Core::OutputFormats::TXT do
  let(:io) { StringIO.new }

  subject { described_class.new(io) }

  describe "#<<" do
    context "when the value does define a #to_s method" do
      module TestTXTOutputFormat
        class Value

          def initialize(a,b,c)
            @a = a
            @b = b
            @c = c
          end

          def to_s
            "a=#{@a} b=#{@b} c=#{@c}"
          end

        end
      end

      let(:value) { TestTXTOutputFormat::Value.new(1,2,3) }

      it "must call #to_s on the value and write the result to the output stream as a new line" do
        subject << value

        expect(io.string).to eq("a=1 b=2 c=3\n")
      end

      it "must call flush after writing the line" do
        expect(io).to receive(:puts).with("a=1 b=2 c=3")
        expect(io).to receive(:flush)

        subject << value
      end
    end
  end
end
