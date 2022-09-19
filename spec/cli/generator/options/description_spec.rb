require 'spec_helper'
require 'ronin/core/cli/generator/options/description'
require 'ronin/core/cli/command'
require 'ronin/core/cli/generator'

describe Ronin::Core::CLI::Generator::Options::Description do
  module TestDescriptionOption
    class TestCommand < Ronin::Core::CLI::Command
      include Ronin::Core::CLI::Generator
      include Ronin::Core::CLI::Generator::Options::Description

      template_dir 'test'
    end
  end

  let(:command_class) { TestDescriptionOption::TestCommand }
  subject { command_class.new }

  let(:description) { 'Foo bar baz' }

  describe ".included" do
    subject { command_class }

    it "must add a '-D,--description TEXT' option" do
      expect(subject.options[:description]).to_not be_nil
      expect(subject.options[:description].short).to eq('-D')
      expect(subject.options[:description].value).to_not be_nil
      expect(subject.options[:description].value.type).to eq(String)
      expect(subject.options[:description].value.usage).to eq('TEXT')
      expect(subject.options[:description].desc).to eq('A longer description')
    end
  end

  describe "#parse_options" do
    context "when given '--description TEXT'" do
      let(:argv) { ['--description', description] }

      before { subject.parse_options(argv) }

      it "must set #description" do
        expect(subject.description).to eq(description)
      end
    end
  end
end
