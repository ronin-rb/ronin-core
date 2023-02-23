#!/usr/bin/env ruby
require 'bundler/setup'

require 'ronin/core/cli/command_shell'

#
# An example interactive CLI shell.
#
class TestShell < Ronin::Core::CLI::CommandShell

  shell_name 'test'

  command :foo, summary: 'Command with no arguments'
  def foo
    puts "no args"
  end

  command :bar, usage:       'ARG',
                completions: %w[arg1 arg2],
                summary:     'Command with one argument'
  def bar(arg)
    puts "arg=#{arg}"
  end

  command :baz, usage:   '[ARG]',
                summary: 'Command with optional argument'
  def baz(arg=nil)
    puts "arg=#{arg}"
  end

  command :qux, usage:   '[ARGS...]',
                summary: 'Command with repeating arguments'
  def qux(*args)
    puts "args=#{args.join(' ')}"
  end

end

TestShell.start
