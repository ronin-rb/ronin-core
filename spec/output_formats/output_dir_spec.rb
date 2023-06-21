require 'spec_helper'
require 'ronin/core/output_formats/output_dir'

require 'tmpdir'

describe Ronin::Core::OutputFormats::OutputDir do
  let(:tmpdir) { Dir.mktmpdir('ronin-core') }
  let(:path)   { File.join(tmpdir,'output_dir') }

  subject { described_class.new(path) }

  describe "#initialize" do
    it "must set #path" do
      expect(subject.path).to eq(path)
    end

    it "must create the given directory path" do
      expect(File.directory?(subject.path)).to be(true)
    end
  end

  describe ".open" do
    subject { described_class }

    context "when no block is given" do
      it "must return the new output directory object" do
        output_dir = subject.open(path)

        expect(output_dir).to be_kind_of(described_class)
        expect(output_dir.path).to eq(path)
      end
    end

    context "when given a block" do
      it "must yield the new the output directory object" do
        expect { |b|
          subject.open(path,&b)
        }.to yield_with_args(described_class)
      end
    end
  end

  describe "#close" do
    it "must define a place-holder #close method" do
      subject.close
    end
  end
end
