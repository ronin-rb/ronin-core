require 'spec_helper'
require 'ronin/core/metadata/authors/author'

describe Ronin::Core::Metadata::Authors::Author do
  let(:name)    { 'John Smith'               }
  let(:email)   { 'john.smith@example.com'   }
  let(:pgp)     { '0x123456789'              }
  let(:website) { 'https://jsmith.name'      }
  let(:blog)    { 'https://blog.jsmith.name' }
  let(:github)  { 'jsmith_github'            }
  let(:gitlab)  { 'jsmith_gitlab'            }
  let(:twitter) { 'jsmith_twitter'           }
  let(:discord) { 'jsmith_discord'           }

  describe "#initialize" do
    subject { described_class.new(name) }

    it "must set #name" do
      expect(subject.name).to eq(name)
    end

    context "when given the email: keyword argument" do
      subject { described_class.new(name, email: email) }

      it "must set #email" do
        expect(subject.email).to eq(email)
      end
    end

    context "when given the pgp: keyword argument" do
      subject { described_class.new(name, pgp: pgp) }

      it "must set #pgp" do
        expect(subject.pgp).to eq(pgp)
      end
    end

    context "when given the website: keyword argument" do
      subject { described_class.new(name, website: website) }

      it "must set #website" do
        expect(subject.website).to eq(website)
      end
    end

    context "when given the blog: keyword argument" do
      subject { described_class.new(name, blog: blog) }

      it "must set #blog" do
        expect(subject.blog).to eq(blog)
      end
    end

    context "when given the github: keyword argument" do
      subject { described_class.new(name, github: github) }

      it "must set #github" do
        expect(subject.github).to eq(github)
      end
    end

    context "when given the gitlab: keyword argument" do
      subject { described_class.new(name, gitlab: gitlab) }

      it "must set #gitlab" do
        expect(subject.gitlab).to eq(gitlab)
      end
    end

    context "when given the twitter: keyword argument" do
      subject { described_class.new(name, twitter: twitter) }

      it "must set #twitter" do
        expect(subject.twitter).to eq(twitter)
      end
    end

    context "when given the discord: keyword argument" do
      subject { described_class.new(name, discord: discord) }

      it "must set #discord" do
        expect(subject.discord).to eq(discord)
      end
    end
  end

  subject do
    described_class.new(name, email:   email,
                              pgp:     pgp,
                              github:  github,
                              gitlab:  gitlab,
                              twitter: twitter,
                              discord: discord)
  end

  describe "#email?" do
    context "when #email is set" do
      subject { described_class.new(name, email: email) }

      it "must return true" do
        expect(subject.email?).to be(true)
      end
    end

    context "when #email is not set" do
      subject { described_class.new(name) }

      it "must return false" do
        expect(subject.email?).to be(false)
      end
    end
  end

  describe "#pgp?" do
    context "when #pgp is set" do
      subject { described_class.new(name, pgp: pgp) }

      it "must return true" do
        expect(subject.pgp?).to be(true)
      end
    end

    context "when #pgp is not set" do
      subject { described_class.new(name) }

      it "must return false" do
        expect(subject.pgp?).to be(false)
      end
    end
  end

  describe "#website?" do
    context "when #website is set" do
      subject { described_class.new(name, website: website) }

      it "must return true" do
        expect(subject.website?).to be(true)
      end
    end

    context "when #website is not set" do
      subject { described_class.new(name) }

      it "must return false" do
        expect(subject.website?).to be(false)
      end
    end
  end

  describe "#blog?" do
    context "when #blog is set" do
      subject { described_class.new(name, blog: blog) }

      it "must return true" do
        expect(subject.blog?).to be(true)
      end
    end

    context "when #blog is not set" do
      subject { described_class.new(name) }

      it "must return false" do
        expect(subject.blog?).to be(false)
      end
    end
  end

  describe "#github?" do
    context "when #github is set" do
      subject { described_class.new(name, github: github) }

      it "must return true" do
        expect(subject.github?).to be(true)
      end
    end

    context "when #github is not set" do
      subject { described_class.new(name) }

      it "must return false" do
        expect(subject.github?).to be(false)
      end
    end
  end

  describe "#gitlab?" do
    context "when #gitlab is set" do
      subject { described_class.new(name, gitlab: gitlab) }

      it "must return true" do
        expect(subject.gitlab?).to be(true)
      end
    end

    context "when #gitlab is not set" do
      subject { described_class.new(name) }

      it "must return false" do
        expect(subject.gitlab?).to be(false)
      end
    end
  end

  describe "#twitter?" do
    context "when #twitter is set" do
      subject { described_class.new(name, twitter: twitter) }

      it "must return true" do
        expect(subject.twitter?).to be(true)
      end
    end

    context "when #twitter is not set" do
      subject { described_class.new(name) }

      it "must return false" do
        expect(subject.twitter?).to be(false)
      end
    end
  end

  describe "#discord?" do
    context "when #discord is set" do
      subject { described_class.new(name, discord: discord) }

      it "must return true" do
        expect(subject.discord?).to be(true)
      end
    end

    context "when #discord is not set" do
      subject { described_class.new(name) }

      it "must return false" do
        expect(subject.discord?).to be(false)
      end
    end
  end

  describe "#github_url" do
    context "when #github is set" do
      subject { described_class.new(name, github: github) }

      it "must return the 'https://github.com/...' URL" do
        expect(subject.github_url).to eq("https://github.com/#{github}")
      end

      context "but the twitter handle starts with a '@'" do
        subject { described_class.new(name, github: "@#{github}") }

        it "must omit the leading '@' character" do
          expect(subject.github_url).to eq("https://github.com/#{github}")
        end
      end
    end

    context "when #github is not set" do
      subject { described_class.new(name) }

      it "must return nil" do
        expect(subject.github_url).to be(nil)
      end
    end
  end

  describe "#gitlab_url" do
    context "when #gitlab is set" do
      subject { described_class.new(name, gitlab: gitlab) }

      it "must return the 'https://gitlab.com/...' URL" do
        expect(subject.gitlab_url).to eq("https://gitlab.com/#{gitlab}")
      end

      context "but the twitter handle starts with a '@'" do
        subject { described_class.new(name, gitlab: "@#{gitlab}") }

        it "must omit the leading '@' character" do
          expect(subject.gitlab_url).to eq("https://gitlab.com/#{gitlab}")
        end
      end
    end

    context "when #gitlab is not set" do
      subject { described_class.new(name) }

      it "must return nil" do
        expect(subject.gitlab_url).to be(nil)
      end
    end
  end

  describe "#twitter_url" do
    context "when #twitter is set" do
      subject { described_class.new(name, twitter: twitter) }

      it "must return the 'https://twitter.com/...' URL" do
        expect(subject.twitter_url).to eq("https://twitter.com/#{twitter}")
      end

      context "but the twitter handle starts with a '@'" do
        subject { described_class.new(name, twitter: "@#{twitter}") }

        it "must omit the leading '@' character" do
          expect(subject.twitter_url).to eq("https://twitter.com/#{twitter}")
        end
      end
    end

    context "when #twitter is not set" do
      subject { described_class.new(name) }

      it "must return nil" do
        expect(subject.twitter_url).to be(nil)
      end
    end
  end

  describe "#to_s" do
    context "when #name and #email are set" do
      subject { described_class.new(name, email: email) }

      it "must return a formatted email address with the name" do
        expect(subject.to_s).to eq("#{name} <#{email}>")
      end
    end

    context "when only #name is set" do
      subject { described_class.new(name) }

      it "must return #name" do
        expect(subject.to_s).to eq(name)
      end
    end
  end
end
