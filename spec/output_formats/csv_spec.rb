require 'spec_helper'
require 'ronin/core/output_formats/csv'

require 'csv'

describe Ronin::Core::OutputFormats::CSV do
  let(:io) { StringIO.new }

  subject { described_class.new(io) }

  describe "#<<" do
    context "when the value does define a #to_csv method" do
      module TestCSVOutputFormat
        class Value

          def initialize(a,b,c)
            @a = a
            @b = b
            @c = c
          end

          def to_csv
            CSV.generate_line([@a,@b,@c])
          end

        end
      end

      let(:value) { TestCSVOutputFormat::Value.new(1,2,3) }

      it "must convert the value to CSV and write it to the output stream" do
        subject << value

        expect(io.string).to eq("1,2,3\n")
      end

      it "must call flush after writing the CSV line" do
        expect(io).to receive(:write).with("1,2,3\n")
        expect(io).to receive(:flush)

        subject << value
      end
    end

    context "when the value does not define a #to_csv method" do
      module TestCSVOutputFormat
        class ValueWithoutToCSV
        end
      end

      let(:value) { TestCSVOutputFormat::ValueWithoutToCSV.new }

      it do
        expect {
          subject << value
        }.to raise_error(NotImplementedError,"output value must define a #to_csv method: #{value.inspect}")
      end
    end
  end
end
