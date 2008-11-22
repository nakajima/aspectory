$LOAD_PATH << File.dirname(__FILE__) + '/booty_call'
$LOAD_PATH << File.dirname(__FILE__) + '/core_ext'

module BootyCall
  VERSION = '0.0.5'
end

require 'rubygems'
require 'nakajima'
require 'array'
require 'method'
require 'callbacker'
require 'observed_method'
require 'introspector'
require 'hook'