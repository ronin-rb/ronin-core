require 'spec_helper'
require 'ronin/core/output_formats/output_format'

require 'stringio'

describe Ronin::Core::OutputFormats::OutputFormat do
  let(:io) { StringIO.new }

  subject { described_class.new(io) }

  describe "#initialize" do
    it "must set #io" do
      expect(subject.io).to be(io)
    end
  end

  describe ".open" do
    subject { described_class }

    let(:path) { 'path/to/file' }
    let(:file) { double('File') }

    context "when no block is given" do
      it "must open the file for writing and return the new output format object" do
        expect(File).to receive(:open).with(path,'w').and_return(file)

        output_format = subject.open(path)

        expect(output_format).to be_kind_of(described_class)
        expect(output_format.io).to be(file)
      end
    end

    context "when given a block" do
      it "must open the file for writing, yiled new the output format object, then close the file" do
        expect(File).to receive(:open).with(path,'w').and_return(file)
        expect(file).to receive(:close)

        expect { |b|
          subject.open(path,&b)
        }.to yield_with_args(described_class)
      end
    end
  end

  describe "#<<" do
    it do
      expect {
        subject << [1,2,3]
      }.to raise_error(NotImplementedError,"#{described_class}#<< was not implemented")
    end
  end

  describe "#close" do
    it "must close #io" do
      expect(io).to receive(:close)

      subject.close
    end
  end
end
