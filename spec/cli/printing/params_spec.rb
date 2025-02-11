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
