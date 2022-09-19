require 'spec_helper'
require 'ronin/core/cli/printing/os'
require 'ronin/core/cli/command'

describe Ronin::Core::CLI::Printing::OS do
  module TestPrintingOS
    class TestCommand < Ronin::Core::CLI::Command
      include Ronin::Core::CLI::Printing::OS
    end
  end

  let(:command_class) { TestPrintingOS::TestCommand }
  subject { command_class.new }

  describe "#os_name" do
    context "when given :unix" do
      it "must return 'UNIX'" do
        expect(subject.os_name(:unix)).to eq('UNIX')
      end
    end

    context "when given :bsd" do
      it "must return 'BSD'" do
        expect(subject.os_name(:bsd)).to eq('BSD')
      end
    end

    context "when given :freebsd" do
      it "must return 'FreeBSD'" do
        expect(subject.os_name(:freebsd)).to eq('FreeBSD')
      end
    end

    context "when given :openbsd" do
      it "must return 'OpenBSD'" do
        expect(subject.os_name(:openbsd)).to eq('OpenBSD')
      end
    end

    context "when given :netbsd" do
      it "must return 'NetBSD'" do
        expect(subject.os_name(:netbsd)).to eq('NetBSD')
      end
    end

    context "when given :linux" do
      it "must return 'Linux'" do
        expect(subject.os_name(:linux)).to eq('Linux')
      end
    end

    context "when given :macos" do
      it "must return 'macOS'" do
        expect(subject.os_name(:macos)).to eq('macOS')
      end
    end

    context "when given :windows" do
      it "must return 'Windows'" do
        expect(subject.os_name(:windows)).to eq('Windows')
      end
    end
  end
end
