require 'rspec'
require 'simplecov'
SimpleCov.start

ENV.delete('XDG_CACHE_HOME')
ENV.delete('XDG_CONFIG_HOME')
ENV.delete('XDG_DATA_HOME')

require 'ronin/core/version'

include Ronin
