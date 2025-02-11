require 'spec_helper'
require 'ronin/core/cli/printing/arch'

describe "Ronin::Core::CLI::Printing::Arch" do
  subject { Ronin::Core::CLI::Printing::Arch }

  it "must act as an alias for Ronin::Core::CLI::Text::Arch" do
    expect(subject).to be(Ronin::Core::CLI::Text::Arch)
  end
end
