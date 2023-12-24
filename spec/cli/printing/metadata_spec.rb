require 'spec_helper'
require 'ronin/core/cli/printing/metadata'
require 'ronin/core/cli/command'
require 'ronin/core/metadata/authors'
require 'ronin/core/metadata/description'
require 'ronin/core/metadata/references'

describe Ronin::Core::CLI::Printing::Metadata do
  module TestPrintingMetadata
    class TestCommand < Ronin::Core::CLI::Command
      include Ronin::Core::CLI::Printing::Metadata
    end
  end

  let(:command_class) { TestPrintingMetadata::TestCommand }
  subject { command_class.new }

  describe ".included" do
    subject { command_class }

    it "must add a -v,--verbose option" do
      expect(subject.options[:verbose]).to_not be_nil
    end
  end

  describe "#print_authors" do
    module TestPrintingAuthors
      class WithoutAuthors
        include Ronin::Core::Metadata::Authors
      end

      class WithAuthors
        include Ronin::Core::Metadata::Authors

        author 'John Doe', email:    'john.doe@example.com',
                           pgp:      '0x123456789',
                           website:  'https://johndoe.name',
                           blog:     'https://johndoe.name/blog',
                           github:   '@johndoe',
                           gitlab:   '@johndoe',
                           twitter:  '@johndoe',
                           mastodon: '@johndoe@mastodon.social',
                           discord:  'https://discord.gg/1234'

        author 'John Smith', email:    'john.smith@example.com',
                             pgp:      '0xABCDEF',
                             website:  'https://johnsmith.name',
                             blog:     'https://johnsmith.name/blog',
                             github:   '@john.smith',
                             gitlab:   '@john.smith',
                             twitter:  '@john.smith',
                             mastodon: '@john.smith@mastodon.social',
                             discord:  'https://discord.gg/ABCDEF'
      end
    end

    context "when the class does not have any authors" do
      let(:klass) { TestPrintingAuthors::WithoutAuthors }

      it "must not print anything" do
        expect {
          subject.print_authors(klass)
        }.to_not output.to_stdout
      end
    end

    context "when the class does have authors" do
      let(:klass) { TestPrintingAuthors::WithAuthors }

      it "must print 'Authors:' and a list of authors" do
        expect {
          subject.print_authors(klass)
        }.to output(
          [
            'Authors:',
            '',
            "  * #{klass.authors[0]}",
            "  * #{klass.authors[1]}",
            '',
            ''
          ].join($/)
        ).to_stdout
      end

      context "when --verbose mode is enabled" do
        before { allow(subject).to receive(:verbose?).and_return(true) }

        it "must print the authors and any author metadata as indented lists" do
          expect {
            subject.print_authors(klass)
          }.to output(
            [
              'Authors:',
              '',
              "  * #{klass.authors[0]}",
              "    * PGP: #{klass.authors[0].pgp}",
              "    * Website: #{klass.authors[0].website}",
              "    * Blog: #{klass.authors[0].blog}",
              "    * GitHub: #{klass.authors[0].github_url}",
              "    * GitLab: #{klass.authors[0].gitlab_url}",
              "    * Twitter: #{klass.authors[0].twitter_url}",
              "    * Mastodon: #{klass.authors[0].mastodon_url}",
              "    * Discord: #{klass.authors[0].discord}",
              "  * #{klass.authors[1]}",
              "    * PGP: #{klass.authors[1].pgp}",
              "    * Website: #{klass.authors[1].website}",
              "    * Blog: #{klass.authors[1].blog}",
              "    * GitHub: #{klass.authors[1].github_url}",
              "    * GitLab: #{klass.authors[1].gitlab_url}",
              "    * Twitter: #{klass.authors[1].twitter_url}",
              "    * Mastodon: #{klass.authors[1].mastodon_url}",
              "    * Discord: #{klass.authors[1].discord}",
              '',
              ''
            ].join($/)
          ).to_stdout
        end
      end
    end
  end

  describe "#print_description" do
    module TestPrintingDescription
      class WithoutDescription
        include Ronin::Core::Metadata::Description
      end

      class WithDescription
        include Ronin::Core::Metadata::Description

        description <<~DESC
          Foo bar baz

          Qux quux gorge
        DESC
      end
    end

    context "when the class does not have a description" do
      let(:klass) { TestPrintingDescription::WithoutDescription }

      it "must not print anything" do
        expect {
          subject.print_description(klass)
        }.to_not output.to_stdout
      end
    end

    context "when the class does have a description" do
      let(:klass) { TestPrintingDescription::WithDescription }

      it "must print 'Description:' and the indented description text" do
        expect {
          subject.print_description(klass)
        }.to output(
          [
            'Description:',
            '',
            "  #{klass.description.lines[0].chomp}",
            "  #{klass.description.lines[1].chomp}",
            "  #{klass.description.lines[2].chomp}",
            '',
            ''
          ].join($/)
        ).to_stdout
      end
    end
  end

  describe "#print_references" do
    module TestPrintingReferences
      class WithoutReferences
        include Ronin::Core::Metadata::References
      end

      class WithReferences
        include Ronin::Core::Metadata::References

        references [
          'https://example.com/url1',
          'https://example.com/url2'
        ]
      end
    end

    context "when the class has no references" do
      let(:klass) { TestPrintingReferences::WithoutReferences }

      it "must not print anything" do
        expect {
          subject.print_references(klass)
        }.to_not output.to_stdout
      end
    end

    context "when the class has references" do
      let(:klass) { TestPrintingReferences::WithReferences }

      it "must print 'References:' and the list of reference URLs" do
        expect {
          subject.print_references(klass)
        }.to output(
          [
            'References:',
            '',
            "  * #{klass.references[0]}",
            "  * #{klass.references[1]}",
            '',
            ''
          ].join($/)
        ).to_stdout
      end
    end
  end
end
