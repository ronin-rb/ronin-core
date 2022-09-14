require 'spec_helper'
require 'ronin/core/cli/param_option'
require 'ronin/core/cli/command'

describe Ronin::Core::CLI::ParamOption do
  module TestParamOption
    class TestCommand < Ronin::Core::CLI::Command
      include Ronin::Core::CLI::ParamOption
    end
  end

  let(:command_class) { TestParamOption::TestCommand }

  describe ".included" do
    subject { command_class }

    it "must add a -p,--param option to the options" do
      expect(subject.options[:param]).to_not be_nil
      expect(subject.options[:param].value?).to be(true)
      expect(subject.options[:param].value.type).to be_kind_of(Regexp)
      expect(subject.options[:param].value.usage).to eq('NAME=VALUE')
      expect(subject.options[:param].desc).to eq('Sets a param')
    end
  end

  subject { command_class.new }

  describe "#initialize" do
    it "must set #params to an empty Hash" do
      expect(subject.params).to eq({})
    end
  end

  describe "options" do
    context "when given --param foo=bar" do
      before { subject.option_parser.parse(%w[--param foo=bar]) }

      it "must set the 'foo' key to 'bar' in #params" do
        expect(subject.params['foo']).to eq('bar')
      end
    end

    context "when given --param foo=" do
      it do
        expect {
          subject.option_parser.parse(%w[--param foo=])
        }.to raise_error(OptionParser::InvalidArgument)
      end
    end

    context "when given --param =bar" do
      it do
        expect {
          subject.option_parser.parse(%w[--param =bar])
        }.to raise_error(OptionParser::InvalidArgument)
      end
    end

    context "when given --param =" do
      it do
        expect {
          subject.option_parser.parse(%w[--param =])
        }.to raise_error(OptionParser::InvalidArgument)
      end
    end
  end
end
