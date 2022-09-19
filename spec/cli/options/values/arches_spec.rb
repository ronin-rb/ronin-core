require 'spec_helper'
require 'ronin/core/cli/options/values/arches'

describe "Ronin::Core::CLI::Options::Values::ARCHES" do
  subject { Ronin::Core::CLI::Options::Values::ARCHES }

  it "must map 'x86' to :x86" do
    expect(subject['x86']).to eq(:x86)
  end

  it "must map 'x86-64' to :x86_64" do
    expect(subject['x86-64']).to eq(:x86_64)
  end

  it "must map 'amd64' to :x86_64" do
    expect(subject['amd64']).to eq(:x86_64)
  end

  it "must map 'ia64' to :ia64" do
    expect(subject['ia64']).to eq(:ia64)
  end

  it "must map 'ppc' to :ppc" do
    expect(subject['ppc']).to eq(:ppc)
  end

  it "must map 'ppc64' to :ppc64" do
    expect(subject['ppc64']).to eq(:ppc64)
  end

  it "must map 'arm' to :arm" do
    expect(subject['arm']).to eq(:arm)
  end

  it "must map 'armbe' to :arm_be" do
    expect(subject['armbe']).to eq(:arm_be)
  end

  it "must map 'arm64' to :arm64" do
    expect(subject['arm64']).to eq(:arm64)
  end

  it "must map 'arm64be' to :arm64_be" do
    expect(subject['arm64be']).to eq(:arm64_be)
  end

  it "must map 'mips' to :mips" do
    expect(subject['mips']).to eq(:mips)
  end

  it "must map 'mipsle' to :mips_le" do
    expect(subject['mipsle']).to eq(:mips_le)
  end

  it "must map 'mips64' to :mips64" do
    expect(subject['mips64']).to eq(:mips64)
  end

  it "must map 'mips64le' to :mips64_le" do
    expect(subject['mips64le']).to eq(:mips64_le)
  end
end
