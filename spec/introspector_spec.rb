require 'spec/spec_helper'

describe GotYoBack::Introspector do
  attr_reader :klass, :introspector
  
  before(:each) do
    @klass = Class.new { def foo; :foo end }
    @introspector = GotYoBack::Introspector.new(@klass)
  end
  
  it "knows defined methods" do
    introspector.defined_methods.should == [:foo]
  end
  
  it "only observes klass once" do
    introspector.observe_klass!.should be_true
  end
  
  describe "observing a method" do
    it "is stored in #observed_methods" do
      introspector.observe(:bar)
      introspector.observing?(:bar).should be_true
    end

    it "ceases when method gets defined" do
      introspector.observe(:bar)
      klass.class_eval { def bar; :bar end }
      introspector.observing?(:bar).should be_false
    end
    
    it "allows callbacks for when methods get defined" do
      called = false
      introspector.observe(:bar) { called = true }
      klass.class_eval { def bar; :bar end }
      called.should be_true
    end
  end
end