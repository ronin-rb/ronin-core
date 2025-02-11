require 'spec_helper'
require 'ronin/core/cli/text/params'

require 'ronin/core/cli/command'
require 'ronin/core/params/mixin'

describe Ronin::Core::CLI::Text::Params do
  module TestCLITextParams
    class TestClass

      include Ronin::Core::Params::Mixin

      param :foo, String, required: true,
                          desc: 'Foo param'
      param :bar, Integer, default: 42,
                           desc: 'Bar param'
      param :baz, Enum[:one, :two], desc: 'Baz param'

    end

    class TestClassWithoutParams
      include Ronin::Core::Params::Mixin
    end

    class TestCommand < Ronin::Core::CLI::Command
      include Ronin::Core::CLI::Text::Params
    end
  end

  let(:test_class)   { TestCLITextParams::TestClass   }
  let(:test_command) { TestCLITextParams::TestCommand }
  subject { test_command.new }

  describe "#param_type_name" do
    let(:name)  { :foo }
    let(:type)  { Ronin::Core::Params::Types::Integer.new }
    let(:param) do
      Ronin::Core::Params::Param.new(name,type, desc: 'Test param')
    end

    it "must return the param type's class name without the suffix" do
      expect(subject.param_type_name(param)).to eq('Integer')
    end
  end

  describe "#param_usage" do
    let(:name)  { :foo }
    let(:param) do
      Ronin::Core::Params::Param.new(name,type, desc: 'Test param')
    end

    context "when given a param with a Boolean type" do
      let(:type)  { Ronin::Core::Params::Types::Boolean.new }

      it "must return 'BOOL'" do
        expect(subject.param_usage(param)).to eq('BOOL')
      end
    end

    context "when given a param with an Integer type" do
      let(:type)  { Ronin::Core::Params::Types::Integer.new }

      it "must return 'NUM'" do
        expect(subject.param_usage(param)).to eq('NUM')
      end
    end

    context "when given a param with a Float type" do
      let(:type)  { Ronin::Core::Params::Types::Float.new }

      it "must return 'FLOAT'" do
        expect(subject.param_usage(param)).to eq('FLOAT')
      end
    end

    context "when given a param with a Regexp type" do
      let(:type)  { Ronin::Core::Params::Types::Regexp.new }

      it "must return '/REGEX/'" do
        expect(subject.param_usage(param)).to eq('/REGEX/')
      end
    end

    context "when given a param with a URI type" do
      let(:type)  { Ronin::Core::Params::Types::URI.new }

      it "must return 'URL'" do
        expect(subject.param_usage(param)).to eq('URL')
      end
    end

    context "when given a param with a String type" do
      let(:type)  { Ronin::Core::Params::Types::String.new }

      it "must return the upcased version of the param name" do
        expect(subject.param_usage(param)).to eq(name.upcase)
      end
    end

    context "when given a param with a Enum type" do
      let(:type)  { Ronin::Core::Params::Types::Enum[:bar, :baz] }

      it "must return the upcased version of the param name" do
        expect(subject.param_usage(param)).to eq(name.upcase)
      end
    end
  end
end
