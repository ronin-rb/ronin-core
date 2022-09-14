require 'spec_helper'
require 'ronin/core/metadata/authors'

describe Ronin::Core::Metadata::Authors do
  module TestMetadataAuthor
    class WithNoAuthors
      include Ronin::Core::Metadata::Authors
    end

    class WithOneAuthor
      include Ronin::Core::Metadata::Authors

      author 'John Doe'
    end

    class InheritesAuthors < WithOneAuthor
    end

    class InheritesAndAddsAuthors < WithOneAuthor
      author 'John Smith'
    end

    class WitthMultipleAuthors
      include Ronin::Core::Metadata::Authors

      author 'John Doe'
      author 'John Smith'
    end
  end

  describe ".authors" do
    subject { test_class }

    context "with there are no authors" do
      let(:test_class) { TestMetadataAuthor::WithNoAuthors }

      it "must default to []" do
        expect(subject.authors).to eq([])
      end
    end

    context "with at least one author" do
      let(:test_class) { TestMetadataAuthor::WithOneAuthor }

      it "must contain #{described_class::Author} objects" do
        expect(subject.authors).to all(be_kind_of(described_class::Author))
      end
    end

    context "when the super-class defines it's own authors" do
      let(:test_class)  { TestMetadataAuthor::InheritesAuthors }
      let(:super_class) { test_class.superclass }

      it "must inherit the authors from the super-class" do
        expect(subject.authors).to eq(super_class.authors)
      end

      context "but the sub-class defines additional authors" do
        let(:test_class) { TestMetadataAuthor::InheritesAndAddsAuthors }

        it "must combine the sub-classes authors with the super-classes" do
          expect(subject.authors).to include(*super_class.authors)
        end

        it "must not modify the superclasses authors" do
          expect(super_class.authors).to_not contain_exactly(*subject.authors)
        end
      end
    end
  end

  describe ".author" do
    subject { test_class }

    context "when called with just a name" do
      module TestMetadataAuthor
        class AuthorWithOnlyName
          include Ronin::Core::Metadata::Authors

          author 'John Doe'
        end
      end

      let(:test_class) { TestMetadataAuthor::AuthorWithOnlyName }
      let(:author)     { subject.authors.last }

      it "must initialize the #{described_class::Author} object with that name and add it to .authors" do
        expect(author).to be_kind_of(described_class::Author)
        expect(author.name).to eq('John Doe')
      end
    end

    context "when additional keyword arguments are given" do
      module TestMetadataAuthor
        class AuthorsWithContactInfo
          include Ronin::Core::Metadata::Authors

          author 'John Smith', email:   'john.smith@example.com',
                               pgp:     '0x123456789',
                               website: 'https://jsmith.name',
                               blog:    'https://jsmith.name/blog',
                               github:  'jsmith1',
                               gitlab:  'jsmith2',
                               twitter: 'jsmith3',
                               discord: 'jsmith4'
        end
      end

      let(:test_class) { TestMetadataAuthor::AuthorsWithContactInfo }
      let(:author)     { subject.authors.last }

      it "must initialize #{described_class}::Author with those keywords and add it to .authors" do
        expect(author).to be_kind_of(described_class::Author)
        expect(author.name).to     eq('John Smith')
        expect(author.email).to    eq('john.smith@example.com')
        expect(author.pgp).to      eq('0x123456789')
        expect(author.website).to  eq('https://jsmith.name')
        expect(author.blog).to     eq('https://jsmith.name/blog')
        expect(author.github).to   eq('jsmith1')
        expect(author.gitlab).to   eq('jsmith2')
        expect(author.twitter).to  eq('jsmith3')
        expect(author.discord).to  eq('jsmith4')
      end
    end
  end
end
