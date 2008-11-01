require File.dirname(__FILE__) + '/../lib/got_yo_back.rb'
require 'rubygems'
require 'spec'
require 'rr'

Spec::Runner.configure do |config|
  config.mock_with(:rr)
end