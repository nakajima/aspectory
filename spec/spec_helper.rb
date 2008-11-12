require File.dirname(__FILE__) + '/../lib/booty_call.rb'
require 'rubygems'
require 'spec'
require 'rr'

Spec::Runner.configure do |config|
  config.mock_with(:rr)
end