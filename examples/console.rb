#!/usr/bin/env ruby
require 'bundler/setup'

require 'ronin/core/cli/console'

module Ronin
  module Test
  end
end

Ronin::Core::CLI::Console.start(name: 'ronin-test', context: Ronin::Test)
