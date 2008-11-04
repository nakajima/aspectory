require 'spec/spec_helper'

describe GotYoBack::Hook do
  attr_reader :klass, :object
  
  before(:each) do
    @klass = Class.new do
      include GotYoBack::Hook
      
      after :bar, :call!
      before :foo, :call!
      callback :before, :fizz, :call!
      
      
      def foo; :foo end
      def bar; :bar end
      def fizz; :fizz end
      def buzz; :buzz end
      def call!; @called = true end
      def called?; @called end
    end
    
    @object = klass.new
  end
  
  describe "#before" do
    it "allows callbacks to be defined before methods are" do
      object.should_not be_called
      object.foo
      object.should be_called
    end

    it "allows callbacks to be defined after methods are" do
      klass.before(:buzz, :call!)

      object.should_not be_called
      object.buzz
      object.should be_called
    end
  end
  
  describe "#after" do
    it "allows callbacks to be defined before methods are" do
      object.should_not be_called
      object.bar
      object.should be_called
    end

    it "allows callbacks to be defined after methods are" do
      klass.before(:buzz, :call!)

      object.should_not be_called
      object.buzz
      object.should be_called
    end
  end
  
  describe "#callback" do
    it "allows callbacks to be defined before methods are" do
      object.should_not be_called
      object.fizz
      object.should be_called
    end

    it "allows callbacks to be defined after methods are" do
      klass.callback(:before, :buzz, :call!)

      object.should_not be_called
      object.buzz
      object.should be_called
    end
  end
end