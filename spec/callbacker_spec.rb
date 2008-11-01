require File.dirname(__FILE__) + '/spec_helper'

describe GotYoBack::Callbacker do
  attr_reader :klass, :callbacker
  
  before(:each) do
    @klass = Class.new do
      def foo; :foo end
      def bar; @called = true end
      def fizz(arg=false); @called = arg end 
      def called?; @called end
    end
    
    @callbacker = GotYoBack::Callbacker.new(klass)
  end
  
  describe "#before" do
    it "defines before behavior" do
      @callbacker.before(:foo) { @called = true }
      object = klass.new
      object.foo
      object.should be_called
    end

    it "still performs original behavior" do
      @callbacker.before(:bar) { :ok }
      object = klass.new
      object.bar
      object.should be_called
    end

    it "allows arguments" do
      @callbacker.before(:fizz) { :ok }
      object = klass.new
      object.fizz(true)
      object.should be_called
    end
    
    it "enables halting of method call" do
      @callbacker.before(:bar) { false }
      object = klass.new
      object.bar
      object.should_not be_called
    end
    
    describe "#pristine" do
      it "allows pristine method calling" do
        @callbacker.before(:foo) { @called = true }
        object = klass.new
        object.pristine(:foo)
        object.should_not be_called
      end
    end
  end
end