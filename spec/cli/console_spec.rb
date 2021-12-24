require 'spec_helper'
require 'ronin/core/cli/console'

describe Ronin::Core::CLI::Console do
  describe "#initialize" do
    it "must default #name to 'ronin'" do
      expect(subject.name).to eq('ronin')
    end

    context "when given a name: keyword argument" do
      let(:name) { 'ronin-foo' }

      subject { described_class.new(name: name) }

      it "must set #name" do
        expect(subject.name).to eq(name)
      end
    end

    it "must default #context to nil" do
      expect(subject.context).to be(nil)
    end

    context "when given a context: keyword argument" do
      let(:context) { Object.new }

      subject { described_class.new(context: context) }

      it "must set #context" do
        expect(subject.context).to be(context)
      end
    end
  end

  describe "#configure" do
    before { subject.configure }

    it "must call IRB.setup" do
      expect(IRB.conf.length).to be > 1
    end

    it "must set IRB.conf[:IRB_NAME] to #name" do
      expect(IRB.conf[:IRB_NAME]).to eq(subject.name)
    end

    let(:colors) { subject.colors(STDOUT) }
    let(:red)    { colors::RED }
    let(:bold)   { colors::BOLD }
    let(:reset_intensity) { colors::RESET_INTENSITY }
    let(:reset_color)     { colors::RESET_COLOR     }

    it "must set IRB.conf[:PROMPT][:RONIN]" do
      expect(IRB.conf[:PROMPT][:RONIN]).to eq(
        {
          AUTO_INDENT: true,
          PROMPT_I: "#{red}irb#{bold}(#{reset_intensity}%N#{bold})#{reset_intensity}#{bold}>#{reset_intensity} #{reset_color}",
          PROMPT_S: "#{red}irb#{bold}(#{reset_intensity}%N#{bold})#{reset_intensity}%l #{reset_color}",
          PROMPT_C: "#{red}irb#{bold}(#{reset_intensity}%N#{bold})#{reset_intensity}* #{reset_color}",
          RETURN: "=> %s#{$/}"
        }
      )
    end

    it "must set IRB.conf[:PROMPT_MODE] to :RONIN" do
      expect(IRB.conf[:PROMPT_MODE]).to eq(:RONIN)
    end

    after do
      IRB.conf[:IRB_NAME] = nil
      IRB.conf[:PROMPT].delete(:RONIN)
      IRB.conf[:PROMPT_MODE] = :DEFAULT
    end
  end

  describe "#start" do
    let(:fixtures_dir) { File.expand_path(File.join(__dir__,'fixtures')) }
    let(:console_bin)  { File.join(fixtures_dir,'console') }

    it "must print a prompt then read and evaluate Ruby" do
      output = nil

      IO.popen(console_bin,'r+') do |io|
        io.puts "1 + 1"
        io.puts "exit"

        output = io.read
      end

      expect(output).to eq([
        "Switch to inspect mode.",
        "irb(ronin)> 1 + 1",
        "=> 2",
        "irb(ronin)> exit",
        ''
      ].join($/))
    end
  end
end
