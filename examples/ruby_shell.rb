#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'

require 'ronin/core/cli/ruby_shell'

module Ronin
  #
  # Example namespace that the Ruby shell will spawn within.
  #
  module Test
  end
end

Ronin::Core::CLI::RubyShell.start(name: 'ronin-test', context: Ronin::Test)
