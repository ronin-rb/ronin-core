require 'spec_helper'
require 'ronin/core/cli/printing/params'
require 'ronin/core/cli/command'
require 'ronin/core/params/mixin'

describe Ronin::Core::CLI::Printing::Params do
  module TestPrintingParams
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
      include Ronin::Core::CLI::Printing::Params
    end
  end

  let(:test_class)   { TestPrintingParams::TestClass   }
  let(:test_command) { TestPrintingParams::TestCommand }
  subject { test_command.new }

  describe "#print_params" do
    context "when the class has defined params" do
      it "must print Params: and the params table" do
        expect {
          subject.print_params(test_class)
        }.to output(
          [
            "Params:",
            "",
            "  ┌──────┬─────────┬──────────┬─────────┬─────────────┐",
            "  │ Name │  Type   │ Required │ Default │ Description │",
            "  ├──────┼─────────┼──────────┼─────────┼─────────────┤",
            "  │ foo  │ String  │ Yes      │         │ Foo param   │",
            "  │ bar  │ Integer │ No       │ 42      │ Bar param   │",
            "  │ baz  │ Enum    │ No       │         │ Baz param   │",
            "  │      │         │          │         │  * one      │",
            "  │      │         │          │         │  * two      │",
            "  └──────┴─────────┴──────────┴─────────┴─────────────┘",
            "",
            ""
          ].join($/)
        ).to_stdout
      end
    end

    context "when the class does not have any defined params" do
      let(:test_class) { TestPrintingParams::TestClassWithoutParams }

      it "must not print anything" do
        expect {
          subject.print_params(test_class)
        }.to_not output.to_stdout
      end
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

  describe "#param_description" do
    let(:name)  { :foo }
    let(:param) do
      Ronin::Core::Params::Param.new(name,type, desc: 'Test param')
    end

    context "when given a param with a Enum type" do
      let(:type)  { Ronin::Core::Params::Types::Enum[:bar, :baz] }

      it "must return the param desc text plus all Enum values in list form" do
        expect(subject.param_description(param)).to eq(
          [
            param.desc,
            " * bar",
            " * baz"
          ].join($/)
        )
      end
    end

    context "when given any other type of param" do
      let(:type)  { Ronin::Core::Params::Types::String.new }

      it "must return the param's desc text" do
        expect(subject.param_description(param)).to eq(param.desc)
      end
    end
  end
end
