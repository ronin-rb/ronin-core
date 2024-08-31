require 'spec_helper'
require 'ronin/core/output_formats'

describe Ronin::Core::OutputFormats do
  module TestOutputFormats
    module EmptyOutputFormats
      include Ronin::Core::OutputFormats
    end

    module OutputFormats
      include Ronin::Core::OutputFormats

      register :txt, '.txt', TXT
      register :csv, '.csv', CSV
      register :json, '.json', JSON
      register :ndjson, '.ndjson', NDJSON
    end

    class NoExtOutputFormat < Ronin::Core::OutputFormats::OutputFile; end

    module NoExtOutputFormats
      include Ronin::Core::OutputFormats

      register :no_ext, NoExtOutputFormat
    end
  end

  subject { TestOutputFormats::EmptyOutputFormats }

  describe ".included" do
    it "must add ClassMethods to the module" do
      expect(subject).to be_kind_of(described_class::ClassMethods)
    end
  end

  describe "ClassMethods" do
    describe ".formats" do
      it "must return an empty Hash by default" do
        expect(subject.formats).to eq({})
      end

      context "when output formats have been registered" do
        subject { TestOutputFormats::OutputFormats }

        it "must return the output format names and classes" do
          expect(subject.formats).to eq(
            {
              txt:    described_class::TXT,
              csv:    described_class::CSV,
              json:   described_class::JSON,
              ndjson: described_class::NDJSON
            }
          )
        end
      end
    end

    describe ".file_exts" do
      it "must return an empty Hash by default" do
        expect(subject.formats).to eq({})
      end

      context "when output formats have been registered" do
        subject { TestOutputFormats::OutputFormats }

        it "must return the output format names and classes" do
          expect(subject.file_exts).to eq(
            {
              '.txt'    => described_class::TXT,
              '.csv'    => described_class::CSV,
              '.json'   => described_class::JSON,
              '.ndjson' => described_class::NDJSON
            }
          )
        end
      end

      context "when output formats without extension have been registered" do
        subject { TestOutputFormats::NoExtOutputFormats }

        it "must return an empty Hash" do
          expect(subject.file_exts).to eq({})
        end
      end
    end

    describe ".register" do
      subject { TestOutputFormats::OutputFormats }

      it "must register the output format in #formats with the given name" do
        expect(subject.formats[:txt]).to be(described_class::TXT)
      end

      it "must register the output format in #file_exts with the given ext" do
        expect(subject.file_exts['.txt']).to be(described_class::TXT)
      end

      context "without file extension" do
        subject { TestOutputFormats::NoExtOutputFormats }

        it "must register the output format in #formats with the given name" do
          expect(subject.formats[:no_ext]).to be(TestOutputFormats::NoExtOutputFormat)
        end

        it "must not register the output format in #file_exts" do
          expect(subject.file_exts).to eq({})
        end
      end
    end

    describe ".infer_from" do
      subject { TestOutputFormats::OutputFormats }

      context "when the path's file extension exists in #file_exts" do
        it "must return that output format class" do
          expect(subject.infer_from('file.json')).to be(described_class::JSON)
        end
      end

      context "when the path's file extension is unknown" do
        it "must return #{described_class}::TXT" do
          expect(subject.infer_from('file.log')).to be(described_class::TXT)
        end
      end

      context "when the path has no file extension" do
        it "must return #{described_class}::TXT" do
          expect(subject.infer_from('file')).to be(described_class::TXT)
        end
      end
    end
  end
end
