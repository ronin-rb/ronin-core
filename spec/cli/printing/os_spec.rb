require 'spec_helper'
require 'ronin/core/cli/printing/os'

describe "Ronin::Core::CLI::Printing::OS" do
  subject { Ronin::Core::CLI::Printing::OS }

  it "must act as an alias for Ronin::Core::CLI::Text::OS" do
    expect(subject).to be(Ronin::Core::CLI::Text::OS)
  end
end
