require 'spec_helper'
require 'ronin/core/metadata/author'

describe Ronin::Core::Metadata::Author do
  describe ".author" do
    subject { test_class }

    context "and when author is not set in the shell class" do
      module TestMetadataAuthor
        class WithNoAuthorSet
          include Ronin::Core::Metadata::Author
        end
      end

      let(:test_class) { TestMetadataAuthor::WithNoAuthorSet }

      it "must default to nil" do
        expect(subject.author).to be(nil)
      end
    end

    context "and when author name is set in the shell class" do
      module TestMetadataAuthor
        class WithAuthorNameSet
          include Ronin::Core::Metadata::Author

          author 'John Smith'
        end
      end

      let(:test_class) { TestMetadataAuthor::WithAuthorNameSet }

      it "must return the set author name" do
        expect(subject.author).to eq('John Smith')
      end
    end

    context "and when author name and email are set in the shell class" do
      module TestMetadataAuthor
        class WithAuthorNameAndEmailSet
          include Ronin::Core::Metadata::Author

          author 'John Smith', 'john.smith@example.com'
        end
      end

      let(:test_class) { TestMetadataAuthor::WithAuthorNameAndEmailSet }

      it "must return the set author name and email" do
        expect(subject.author).to eq(
          ['John Smith', 'john.smith@example.com']
        )
      end
    end

    context "but when the author name was set in the superclass" do
      module TestMetadataAuthor
        class InheritsItsAuthorName < WithAuthorNameSet
          include Ronin::Core::Metadata::Author
        end
      end

      let(:test_class) { TestMetadataAuthor::InheritsItsAuthorName }

      it "must return the author name set in the superclass" do
        expect(subject.author).to eq('John Smith')
      end

      context "but the author name is overridden in the sub-class" do
        module TestMetadataAuthor
          class OverridesItsInheritedAuthor < WithAuthorNameSet
            include Ronin::Core::Metadata::Author

            author 'John Smith 2'
          end
        end

        let(:test_class) do
          TestMetadataAuthor::OverridesItsInheritedAuthor
        end

        it "must return the author in the sub-class and the superclass" do
          expect(subject.author).to eq('John Smith 2')
        end
      end
    end

    context "but when the author name and email was set in the superclass" do
      module TestMetadataAuthor
        class InheritsItsAuthorNameAndEmail < WithAuthorNameAndEmailSet
          include Ronin::Core::Metadata::Author
        end
      end

      let(:test_class) { TestMetadataAuthor::InheritsItsAuthorNameAndEmail }

      it "must return the author name set in the superclass" do
        expect(subject.author).to eq(
          ['John Smith', 'john.smith@example.com']
        )
      end

      context "but the author name is overridden in the sub-class" do
        module TestMetadataAuthor
          class OverridesItsInheritedAuthorNameAndEmail < WithAuthorNameAndEmailSet
            include Ronin::Core::Metadata::Author

            author 'John Smith 2', 'john.smith2@example.com'
          end
        end

        let(:test_class) do
          TestMetadataAuthor::OverridesItsInheritedAuthorNameAndEmail
        end

        it "must return the author in the sub-class and the superclass" do
          expect(subject.author).to eq(
            ['John Smith 2', 'john.smith2@example.com']
          )
        end
      end
    end
  end
end
