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
            "  └──────┴─────────┴──────────┴─────────┴─────────────┘",
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
end
