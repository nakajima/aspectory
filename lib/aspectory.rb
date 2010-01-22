$LOAD_PATH << File.dirname(__FILE__) + '/aspectory'
$LOAD_PATH << File.dirname(__FILE__) + '/core_ext'

module BootyCall
  VERSION = '0.0.5'
end

class Symbol
  def to_proc
    Proc.new { |target| target.send(self) }
  end
end

class Object
  def try(sym, *args, &block)
    respond_to?(sym) ? send(sym, *args, &block) : nil
  end

  def tap
    if block_given?
      yield self
      self
    else
      Class.new {
        instance_methods.each { |m| undef_method(m) unless m.to_s =~ /__/ }

        def initialize(target)
          @target = target
        end

        def method_missing(sym, *args, &block)
          @target.send(sym, *args, &block)
          @target
        end
      }.new(self)
    end
  end

  def metaclass
    class << self; self end
  end

  def meta_eval(&block)
    metaclass.instance_eval(&block)
  end

  def meta_def(name, &block)
    meta_eval { define_method(name, &block) }
  end
end

require 'method'
require 'callbacker'
require 'observed_method'
require 'introspector'
require 'hook'
