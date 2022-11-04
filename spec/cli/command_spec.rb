require 'spec_helper'
require 'ronin/core/cli/command'

describe Ronin::Core::CLI::Command do
  it "must inherit from CommandKit::Command" do
    expect(described_class).to be < CommandKit::Command
  end

  it "must include CommandKit::Help::Man" do
    expect(described_class).to include(CommandKit::Help::Man)
  end

  it "must include CommandKit::BugReport" do
    expect(described_class).to include(CommandKit::BugReport)
  end
end
