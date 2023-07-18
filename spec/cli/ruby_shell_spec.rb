require 'spec_helper'
require 'ronin/core/cli/ruby_shell'

describe Ronin::Core::CLI::RubyShell do
  describe "#initialize" do
    it "must default #name to 'ronin'" do
      expect(subject.name).to eq('ronin')
    end

    it "must default #context to nil" do
      expect(subject.context).to be(nil)
    end

    context "when given a name: keyword argument" do
      let(:name) { 'ronin-foo' }

      subject { described_class.new(name: name) }

      it "must set #name" do
        expect(subject.name).to eq(name)
      end
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

    let(:colors)          { subject.colors(STDOUT) }
    let(:red)             { colors::RED }
    let(:bright_red)      { colors::BRIGHT_RED }
    let(:bold)            { colors::BOLD }
    let(:reset_intensity) { colors::RESET_INTENSITY }
    let(:reset_color)     { colors::RESET_COLOR     }

    it "must set IRB.conf[:PROMPT][:RONIN]" do
      expect(IRB.conf[:PROMPT][:RONIN]).to eq(
        {
          AUTO_INDENT: true,
          PROMPT_I: "#{red}irb#{reset_color}#{bold}#{bright_red}(#{reset_color}#{reset_intensity}#{red}%N#{reset_color}#{bold}#{bright_red})#{reset_color}#{reset_intensity}#{bold}#{bright_red}>#{reset_color}#{reset_intensity} ",
          PROMPT_S: "#{red}irb#{reset_color}#{bold}#{bright_red}(#{reset_color}#{reset_intensity}#{red}%N#{reset_color}#{bold}#{bright_red})#{reset_color}#{reset_intensity}%l ",
          PROMPT_C: "#{red}irb#{reset_color}#{bold}#{bright_red}(#{reset_color}#{reset_intensity}#{red}%N#{reset_color}#{bold}#{bright_red})#{reset_color}#{reset_intensity}* ",
          RETURN: "=> %s#{$/}"
        }
      )
    end

    it "must set IRB.conf[:PROMPT_MODE] to :RONIN" do
      expect(IRB.conf[:PROMPT_MODE]).to eq(:RONIN)
    end

    after do
      IRB.conf[:IRB_NAME]    = nil
      IRB.conf[:PROMPT_MODE] = :DEFAULT
      IRB.conf[:PROMPT].delete(:RONIN)
    end
  end

  describe "#start" do
    let(:fixtures_dir) { File.expand_path(File.join(__dir__,'fixtures')) }
    let(:console_bin)  { File.join(fixtures_dir,'irb_command') }

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
