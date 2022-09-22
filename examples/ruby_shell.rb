#!/usr/bin/env ruby
require 'bundler/setup'

require 'ronin/core/cli/ruby_shell'

module Ronin
  module Test
  end
end

Ronin::Core::CLI::RubyShell.start(name: 'ronin-test', context: Ronin::Test)
