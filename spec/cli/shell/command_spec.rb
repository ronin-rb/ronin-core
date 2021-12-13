require 'spec_helper'
require 'ronin/core/cli/shell/command'

describe Ronin::Core::CLI::Shell::Command do
  let(:name)       { :foo }
  let(:usage)      { 'ARG1 [ARG2]' }
  let(:completion) { %w[arg1 arg2] }
  let(:summary)    { 'Foo bar baz' }
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
    described_class.new(name, usage:      usage,
                              completion: completion,
                              summary:    summary,
                              help:       help)
  end

  describe "#initialize" do
    it "must set #name" do
      expect(subject.name).to eq(name)
    end

    context "when the usage: keyword is not given" do
      subject { described_class.new(name, summary: summary) }

      it "must default #usage to nil" do
        expect(subject.usage).to be(nil)
      end
    end

    context "when the usage: keyword is given" do
      it "must set #usage" do
        expect(subject.usage).to eq(usage)
      end
    end

    context "when the completion: keyword is not given" do
      subject { described_class.new(name, summary: summary) }

      it "must default #completion to []" do
        expect(subject.completion).to eq([])
      end
    end

    context "when the completion: keyword is given" do
      it "must set #completion" do
        expect(subject.completion).to eq(completion)
      end
    end

    context "when the help: keyword is not given" do
      subject { described_class.new(name, summary: summary) }

      it "must default #help to #summary" do
        expect(subject.help).to eq(subject.summary)
      end
    end

    context "when the help: keyword is given" do
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
