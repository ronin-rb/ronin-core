require 'spec_helper'
require 'ronin/core/system'

require 'tmpdir'

describe Ronin::Core::System do
  describe ".os" do
    it "must memoize the result" do
      expect(subject.os).to be(subject.os)
    end

    context "when RUBY_PLATFORM contains 'linux'" do
      before { stub_const('RUBY_PLATFORM','x86_64-linux') }

      it { expect(subject.os).to be(:linux) }
    end

    context "when RUBY_PLATFORM contains 'darwin'" do
      before { stub_const('RUBY_PLATFORM','aarch64-darwin') }

      it { expect(subject.os).to be(:macos) }
    end

    context "when RUBY_PLATFORM contains 'freebsd'" do
      before { stub_const('RUBY_PLATFORM','x86_64-freebsd') }

      it { expect(subject.os).to be(:freebsd) }
    end

    context "when RUBY_PLATFORM contains 'openbsd'" do
      before { stub_const('RUBY_PLATFORM','x86_64-openbsd') }

      it { expect(subject.os).to be(:openbsd) }
    end

    context "when RUBY_PLATFORM contains 'netbsd'" do
      before { stub_const('RUBY_PLATFORM','x86_64-netbsd') }

      it { expect(subject.os).to be(:netbsd) }
    end

    context "when Gem.win_platform? returns true" do
      before do
        stub_const('RUBY_PLATFORM','x86_64-mswin')

        expect(Gem).to receive(:win_platform?).and_return(true)
      end

      it { expect(subject.os).to be(:windows) }
    end

    after { subject.instance_variable_set(:@os,nil) }
  end

  describe ".paths" do
    it "must return a split Array of $PATH" do
      expect(subject.paths).to eq(ENV['PATH'].split(File::PATH_SEPARATOR))
    end

    it "must memoize the result" do
      expect(subject.paths).to be(subject.paths)
    end

    context "when $PATH is not set" do
      before do
        stub_const('ENV',{})
      end

      it "must return []" do
        expect(subject.paths).to eq([])
      end
    end

    after { subject.instance_variable_set(:@paths,nil) }
  end

  describe ".installed?" do
    context "when the executable is in one of the .paths directories" do
      it "must return true" do
        expect(subject.installed?('ruby')).to be(true)
      end
    end

    context "when the executable is not in any of the .paths directories" do
      it "must return false" do
        expect(subject.installed?('does_not_exist')).to be(false)
      end
    end
  end

  describe ".downloader" do
    context "when on macOS" do
      before { expect(subject).to receive(:os).and_return(:macos) }

      it "must default to :curl" do
        expect(subject.downloader).to be(:curl)
      end
    end

    context "otherwise" do
      before { expect(subject).to receive(:os).and_return(:linux) }

      context "when both wget and curl are installed" do
        before do
          expect(subject).to receive(:installed?).with('wget').and_return(true)
          expect(subject).to_not receive(:installed?).with('curl')
        end

        it "must return :wget" do
          expect(subject.downloader).to be(:wget)
        end
      end

      context "when wget is installed, but curl is not" do
        before do
          expect(subject).to receive(:installed?).with('wget').and_return(true)
          expect(subject).to_not receive(:installed?).with('curl')
        end

        it "must return :wget" do
          expect(subject.downloader).to be(:wget)
        end
      end

      context "when curl is installed, but wget is not" do
        before do
          expect(subject).to receive(:installed?).with('wget').and_return(false)
          expect(subject).to receive(:installed?).with('curl').and_return(true)
        end

        it "must return :curl" do
          expect(subject.downloader).to be(:curl)
        end
      end
    end

    after { subject.instance_variable_set(:@downloader,nil) }
  end

  describe ".download" do
    let(:url)    { 'https://example.com/test.txt' }
    let(:uri)    { URI.parse(url) }
    let(:tmpdir) { Dir.mktmpdir }

    context "when the destination is a file" do
      let(:dest) { File.join(tmpdir,'dest.txt') }

      context "when .downloader is :wget" do
        before { expect(subject).to receive(:downloader).and_return(:wget) }

        it "must ensure the parent exists, execute 'wget -c -O \#{dest}.part \#{url}', rename the file, and return true" do
          expect(FileUtils).to receive(:mkdir_p).with(File.dirname(dest))
          expect(subject).to receive(:system).with('wget','-c','-O',"#{dest}.part",url).and_return(true)
          expect(FileUtils).to receive(:mv).with("#{dest}.part",dest)

          expect(subject.download(uri,dest)).to eq(dest)
        end

        context "but the command fails" do
          it "must not rename the file, but raise a Ronin::Core::System::DownloadFailed exception" do
            expect(FileUtils).to receive(:mkdir_p).with(File.dirname(dest))
            expect(subject).to receive(:system).with('wget','-c','-O',"#{dest}.part",url).and_return(false)
            expect(FileUtils).to_not receive(:mv).with("#{dest}.part",dest)

            expect {
              subject.download(uri,dest)
            }.to raise_error(Ronin::Core::System::DownloadFailed,"wget command failed: wget -c -O #{dest}.part #{url}")
          end
        end
      end

      context "when .downloader is :curl" do
        before { expect(subject).to receive(:downloader).and_return(:curl) }

        it "must ensure the parent exists, execute 'curl -f -L -C - -o \#{dest}.part \#{url}', rename the file, and return true" do
          expect(FileUtils).to receive(:mkdir_p).with(File.dirname(dest))
          expect(subject).to receive(:system).with('curl','-f','-L','-C','-','-o',"#{dest}.part",url).and_return(true)
          expect(FileUtils).to receive(:mv).with("#{dest}.part",dest)

          expect(subject.download(uri,dest)).to eq(dest)
        end

        context "but the command fails" do
          it "must not rename the file, but raise a Ronin::Core::System::DownloadFailed exception" do
            expect(FileUtils).to receive(:mkdir_p).with(File.dirname(dest))
            expect(subject).to receive(:system).with('curl','-f','-L','-C','-','-o',"#{dest}.part",url).and_return(false)
            expect(FileUtils).to_not receive(:mv).with("#{dest}.part",dest)

            expect {
              subject.download(uri,dest)
            }.to raise_error(Ronin::Core::System::DownloadFailed,"curl command failed: curl -f -L -C - -o #{dest}.part #{url}")
          end
        end
      end

      context "when .downloader is nil" do
        before { expect(subject).to receive(:downloader).and_return(nil) }

        it do
          expect {
            subject.download(uri,dest)
          }.to raise_error(Ronin::Core::System::DownloadFailed,"could not find 'curl' or 'wget' on the system")
        end
      end
    end

    context "when the destination is a directory" do
      let(:dest) { tmpdir }
      let(:derived_dest) { File.join(dest,File.basename(uri.path)) }

      context "when .downloader is :wget" do
        before { expect(subject).to receive(:downloader).and_return(:wget) }

        it "must ensure the dest directory exists, execute 'wget -c -O \#{dest}/\#{file_name}.part \#{url}', rename the file, and return true" do
          expect(FileUtils).to receive(:mkdir_p).with(File.dirname(derived_dest))
          expect(subject).to receive(:system).with('wget','-c','-O',"#{derived_dest}.part",url).and_return(true)
          expect(FileUtils).to receive(:mv).with("#{derived_dest}.part",derived_dest)

          expect(subject.download(uri,dest)).to eq(derived_dest)
        end

        context "but the command fails" do
          it "must not rename the file, but raise a Ronin::Core::System::DownloadFailed exception" do
            expect(FileUtils).to receive(:mkdir_p).with(File.dirname(derived_dest))
            expect(subject).to receive(:system).with('wget','-c','-O',"#{derived_dest}.part",url).and_return(false)
            expect(FileUtils).to_not receive(:mv).with("#{derived_dest}.part",derived_dest)

            expect {
              subject.download(uri,dest)
            }.to raise_error(Ronin::Core::System::DownloadFailed,"wget command failed: wget -c -O #{derived_dest}.part #{url}")
          end
        end
      end

      context "when .downloader is :curl" do
        before { expect(subject).to receive(:downloader).and_return(:curl) }

        it "must ensure the dest directory exists, execute 'curl -f -L -C - -o \#{dest}\#{file_name}.part \#{url}', rename the file, and return the path to the downloaded file" do
          expect(FileUtils).to receive(:mkdir_p).with(File.dirname(derived_dest))
          expect(subject).to receive(:system).with('curl','-f','-L','-C','-','-o',"#{derived_dest}.part",url).and_return(true)
          expect(FileUtils).to receive(:mv).with("#{derived_dest}.part",derived_dest)

          expect(subject.download(uri,dest)).to eq(derived_dest)
        end

        context "but the command fails" do
          it "must not rename the file, but raise a Ronin::Core::System::DownloadFailed exception" do
            expect(FileUtils).to receive(:mkdir_p).with(File.dirname(derived_dest))
            expect(subject).to receive(:system).with('curl','-f','-L','-C','-','-o',"#{derived_dest}.part",url).and_return(false)
            expect(FileUtils).to_not receive(:mv).with("#{derived_dest}.part",derived_dest)

            expect {
              subject.download(uri,dest)
            }.to raise_error(Ronin::Core::System::DownloadFailed,"curl command failed: curl -f -L -C - -o #{derived_dest}.part #{url}")
          end
        end
      end

      context "when .downloader is nil" do
        before { expect(subject).to receive(:downloader).and_return(nil) }

        it do
          expect {
            subject.download(uri,dest)
          }.to raise_error(Ronin::Core::System::DownloadFailed,"could not find 'curl' or 'wget' on the system")
        end
      end
    end
  end
end
