require 'spec_helper'
require 'ronin/core/output_formats/ndjson'

require 'json'

describe Ronin::Core::OutputFormats::NDJSON do
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

      let(:value) { TestJSONOutputFormat::Value.new(1,2,3) }

      it "must convert the value to JSON and write it to the output stream" do
        subject << value

        expect(io.string).to eq(%{{"a":1,"b":2,"c":3}\n})
      end

      it "must call flush after writing the JSON line" do
        expect(io).to receive(:puts).with(%{{"a":1,"b":2,"c":3}})
        expect(io).to receive(:flush)

        subject << value
      end
    end
  end
end
