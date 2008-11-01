$LOAD_PATH << File.dirname(__FILE__) + '/got_yo_back'
$LOAD_PATH << File.dirname(__FILE__) + '/core_ext'

module GotYoBack
  VERSION = '0.0.1'
end

require 'rubygems'
require 'metaid'
require 'symbol'
require 'callbacker'
require 'introspector'