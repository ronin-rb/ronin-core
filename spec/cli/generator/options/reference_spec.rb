require 'spec_helper'
require 'ronin/core/cli/generator/options/reference'
require 'ronin/core/cli/command'
require 'ronin/core/cli/generator'

describe Ronin::Core::CLI::Generator::Options::Reference do
  module TestReferenceOption
    class TestCommand < Ronin::Core::CLI::Command
      include Ronin::Core::CLI::Generator
      include Ronin::Core::CLI::Generator::Options::Reference

      template_dir 'test'
    end
  end

  let(:command_class) { TestReferenceOption::TestCommand }
  subject { command_class.new }

  let(:url1) { 'https://example.com/link1' }
  let(:url2) { 'https://example.com/link2' }

  describe ".included" do
    subject { command_class }

    it "must add a '-R,--reference URL' option" do
      expect(subject.options[:reference]).to_not be_nil
      expect(subject.options[:reference].short).to eq('-R')
      expect(subject.options[:reference].value).to_not be_nil
      expect(subject.options[:reference].value.type).to eq(String)
      expect(subject.options[:reference].value.usage).to eq('URL')
      expect(subject.options[:reference].desc).to eq('Adds a reference URL')
      expect(subject.options[:reference].block).to_not be_nil
    end
  end

  describe "#initialize" do
    it "must initialize #references to an empty Array" do
      expect(subject.references).to eq([])
    end
  end

  describe "#parse_options" do
    context "when given '--reference URL'" do
      let(:argv) { ['--reference', url1, '--reference', url2] }

      before { subject.parse_options(argv) }

      it "must append the URLs to #references" do
        expect(subject.references).to eq([url1, url2])
      end
    end
  end
end
