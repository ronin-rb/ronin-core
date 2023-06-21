require 'spec_helper'
require 'ronin/core/output_formats/json'

require 'json'

describe Ronin::Core::OutputFormats::JSON do
  let(:io) { StringIO.new }

  subject { described_class.new(io) }

  describe "#<<" do
    context "when the value does define a #to_json method" do
      module TestJSONOutputFormat
        class Value

          def initialize(a,b,c)
            @a = a
            @b = b
            @c = c
          end

          def to_json(*args)
            JSON.generate(
              {
                a: @a,
                b: @b,
                c: @c
              }
            )
          end

        end
      end

      context "when the first value is written" do
        let(:value) { TestJSONOutputFormat::Value.new(1,2,3) }

        it "must convert the value to JSON, then write '[' and the JSON to the output stream" do
          subject << value

          expect(io.string).to eq(%{[{"a":1,"b":2,"c":3}})
        end

        it "must call flush after writing the JSON line" do
          expect(io).to receive(:write).with(%{[{"a":1,"b":2,"c":3}})
          expect(io).to receive(:flush)

          subject << value
        end
      end

      context "when the 1+n value is written" do
        let(:value1) { TestJSONOutputFormat::Value.new(1,2,3) }
        let(:value2) { TestJSONOutputFormat::Value.new(4,5,6) }

        it "must convert the value to JSON, then write ',' and the JSON to the output stream" do
          subject << value1
          subject << value2

          expect(io.string).to eq(%{[{"a":1,"b":2,"c":3},{"a":4,"b":5,"c":6}})
        end
      end
    end
  end

  describe "#close" do
    context "when no values have been written" do
      it "must write '[]' to the output stream" do
        subject.close

        expect(io.string).to eq('[]')
      end

      it "must call #close on the output stream" do
        expect(io).to receive(:close)

        subject.close
      end
    end

    context "when at least one value has been written to the streeam" do
      it "must write a closing ']' character to the output stream" do
        subject << {a: 1, b: 2, c: 3}
        subject.close

        expect(io.string).to eq(%{[{"a":1,"b":2,"c":3}]})
      end

      it "must call #close on the output stream" do
        expect(io).to receive(:close)

        subject.close
      end
    end
  end
end
