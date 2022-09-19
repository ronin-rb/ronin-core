require 'spec_helper'
require 'ronin/core/cli/generator/options/summary'
require 'ronin/core/cli/command'
require 'ronin/core/cli/generator'

describe Ronin::Core::CLI::Generator::Options::Summary do
  module TestSummaryOption
    class TestCommand < Ronin::Core::CLI::Command
      include Ronin::Core::CLI::Generator
      include Ronin::Core::CLI::Generator::Options::Summary

      template_dir 'test'
    end
  end

  let(:command_class) { TestSummaryOption::TestCommand }
  subject { command_class.new }

  let(:summary) { 'Foo bar baz' }

  describe ".included" do
    subject { command_class }

    it "must add a '-S,--summary TEXT' option" do
      expect(subject.options[:summary]).to_not be_nil
      expect(subject.options[:summary].short).to eq('-S')
      expect(subject.options[:summary].value).to_not be_nil
      expect(subject.options[:summary].value.type).to eq(String)
      expect(subject.options[:summary].value.usage).to eq('TEXT')
      expect(subject.options[:summary].desc).to eq('One sentence summary')
    end
  end

  describe "#parse_options" do
    context "when given '--summary TEXT'" do
      let(:argv) { ['--summary', summary] }

      before { subject.parse_options(argv) }

      it "must set #summary" do
        expect(subject.summary).to eq(summary)
      end
    end
  end
end
