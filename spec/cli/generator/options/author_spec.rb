require 'spec_helper'
require 'ronin/core/cli/generator/options/author'
require 'ronin/core/cli/command'
require 'ronin/core/cli/generator'

describe Ronin::Core::CLI::Generator::Options::Author do
  module TestAuthorOption
    class TestCommand < Ronin::Core::CLI::Command
      include Ronin::Core::CLI::Generator
      include Ronin::Core::CLI::Generator::Options::Author

      template_dir 'test'
    end
  end

  let(:command_class) { TestAuthorOption::TestCommand }
  subject { command_class.new }

  let(:name)  { 'Foo Bar' }
  let(:email) { 'foo.bar@example.com' }

  describe ".defaultor_name" do
    subject { described_class }

    context "when `git config user.name` is set" do
      before { allow(Ronin::Core::Git).to receive(:user_name).and_return(name) }

      it "must use `git config user.name`" do
        expect(subject.default_name).to eq(name)
      end
    end
    
    context "when `git config user.name` isn't set" do
      before { allow(Ronin::Core::Git).to receive(:user_name).and_return(nil) }

      it "must fallback to using the USERNAME environment variable" do
        expect(subject.default_name).to eq(ENV['USERNAME'])
      end
    end
  end

  describe ".default_email" do
    subject { described_class }

    before { allow(Ronin::Core::Git).to receive(:user_email).and_return(email) }

    it "must use `git config user.email`" do
      expect(subject.default_email).to eq(email)
    end
  end

  describe ".included" do
    subject { command_class }

    it "must add a '-a,--author NAME' option" do
      expect(subject.options[:author]).to_not be_nil
      expect(subject.options[:author].short).to eq('-a')
      expect(subject.options[:author].value).to_not be_nil
      expect(subject.options[:author].value.default.call).to eq(described_class.default_name)
      expect(subject.options[:author].value.type).to eq(String)
      expect(subject.options[:author].value.usage).to eq('NAME')

      if (default_name = described_class.default_name)
        expect(subject.options[:author].desc).to eq("The name of the author (Default: #{default_name})")
      else
        expect(subject.options[:author].desc).to eq("The name of the author")
      end

      expect(subject.options[:author].block).to_not be_nil
    end

    it "must add a '-e,--author-email EMAIL' option" do
      expect(subject.options[:author_email]).to_not be_nil
      expect(subject.options[:author_email].short).to eq('-e')
      expect(subject.options[:author_email].value).to_not be_nil
      expect(subject.options[:author_email].value.default.call).to eq(described_class.default_email)
      expect(subject.options[:author_email].value.type).to eq(String)
      expect(subject.options[:author_email].value.usage).to eq('EMAIL')

      if (default_email = described_class.default_email)
        expect(subject.options[:author_email].desc).to eq("The email address of the author (Default: #{default_email})")
      else
        expect(subject.options[:author_email].desc).to eq("The email address of the author")
      end

      expect(subject.options[:author_email].block).to_not be_nil
    end
  end

  describe "#initialize" do
    it "must set #author_name to #{described_class}.default_name" do
      expect(subject.author_name).to eq(described_class.default_name)
    end

    it "must set #author_email to #{described_class}.default_email" do
      expect(subject.author_email).to eq(described_class.default_email)
    end
  end

  describe "#parse_options" do
    context "when given '--author NAME'" do
      let(:argv) { ['--author', name] }

      before { subject.parse_options(argv) }

      it "must set #uathor_name" do
        expect(subject.author_name).to eq(name)
      end
    end

    context "when given '--author-email NAME'" do
      let(:argv) { ['--author-email', email] }

      before { subject.parse_options(argv) }

      it "must set #uathor_email" do
        expect(subject.author_email).to eq(email)
      end
    end
  end
end
