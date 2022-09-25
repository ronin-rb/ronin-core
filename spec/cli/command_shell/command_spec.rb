require 'spec_helper'
require 'ronin/core/cli/command_shell/command'

describe Ronin::Core::CLI::CommandShell::Command do
  let(:name)        { :foo }
  let(:usage)       { 'ARG1 [ARG2]' }
  let(:completions) { %w[arg1 arg2] }
  let(:summary)     { 'Foo bar baz' }
  let(:help) do
    [
      "Foo bar baz",
      "blah blah blah",
      "",
      "  foo /bar",
      ""
    ].join($/)
  end

  subject do
    described_class.new(name, usage:       usage,
                              completions: completions,
                              summary:     summary,
                              help:        help)
  end

  describe "#initialize" do
    subject { described_class.new(name, summary: summary) }

    it "must set #name" do
      expect(subject.name).to eq(name)
    end

    it "must default #method_name to name" do
      expect(subject.method_name).to eq(name)
    end

    it "must default #usage to nil" do
      expect(subject.usage).to be(nil)
    end

    it "must default #completions to nil" do
      expect(subject.completions).to be(nil)
    end

    it "must default #help to #summary" do
      expect(subject.help).to eq(subject.summary)
    end

    context "when the method_name: keyword is given" do
      let(:method_name) { 'foo2' }

      subject do
        described_class.new(name, method_name: method_name,
                                  summary:     summary)
      end

      it "must override #method_name" do
        expect(subject.method_name).to eq(method_name)
      end
    end

    context "when the usage: keyword is given" do
      subject do
        described_class.new(name, usage:   usage,
                                  summary: summary)
      end

      it "must set #usage" do
        expect(subject.usage).to eq(usage)
      end
    end

    context "when the completions: keyword is given" do
      subject do
        described_class.new(name, usage:       usage,
                                  summary:     summary,
                                  completions: completions)
      end

      it "must set #completions" do
        expect(subject.completions).to eq(completions)
      end
    end

    context "when the help: keyword is given" do
      subject do
        described_class.new(name, usage:   usage,
                                  summary: summary,
                                  help:    help)
      end

      it "must set #help" do
        expect(subject.help).to eq(help)
      end
    end
  end

  describe "#to_s" do
    context "when #usage is set" do
      it "must return the #name and #usage string" do
        expect(subject.to_s).to eq("#{name} #{usage}")
      end
    end

    context "when #usage is not set" do
      subject { described_class.new(name, summary: summary) }

      it "must return the #name as a String" do
        expect(subject.to_s).to eq(name.to_s)
      end
    end
  end
end
