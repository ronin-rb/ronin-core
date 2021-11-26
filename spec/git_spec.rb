require 'spec_helper'
require 'ronin/core/git'

describe Ronin::Core::Git do
  describe ".user_name" do
    let(:user_name) { 'Foo Bar' }

    it "must execute `git config user.name`" do
      expect(subject).to receive(:`).with("git config user.name").and_return("#{user_name}#{$/}")

      expect(subject.user_name).to eq(user_name)
    end

    context "when `git config user.name` returns an empty String" do
      it "must return nil" do
        expect(subject).to receive(:`).with("git config user.name").and_return("")

        expect(subject.user_name).to be(nil)
      end
    end
  end

  describe ".user_email" do
    let(:user_email) { 'foo@example.com' }

    it "must execute `git config user.email`" do
      expect(subject).to receive(:`).with("git config user.email").and_return("#{user_email}#{$/}")

      expect(subject.user_email).to eq(user_email)
    end

    context "when `git config user.email` returns an empty String" do
      it "must return nil" do
        expect(subject).to receive(:`).with("git config user.email").and_return("")

        expect(subject.user_email).to be(nil)
      end
    end
  end

  describe ".github_user" do
    let(:github_user) { 'foo' }

    it "must execute `git config github.user`" do
      expect(subject).to receive(:`).with("git config github.user").and_return("#{github_user}#{$/}")

      expect(subject.github_user).to eq(github_user)
    end

    context "when `git config github.user` returns an empty String" do
      it "must return nil" do
        expect(subject).to receive(:`).with("git config github.user").and_return("")

        expect(subject.github_user).to be(nil)
      end
    end
  end
end
