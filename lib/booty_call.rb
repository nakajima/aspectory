$LOAD_PATH << File.dirname(__FILE__) + '/booty_call'

module BootyCall
  VERSION = '0.0.1'
end

require 'rubygems'
require 'nakajima'
require 'callbacker'
require 'observed_method'
require 'introspector'
require 'hook'