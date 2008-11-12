require 'spec/spec_helper'

describe BootyCall::Introspector do
  attr_reader :klass, :introspector
  
  before(:each) do
    @klass = Class.new { def foo; :foo end }
    @introspector = BootyCall::Introspector.new(@klass)
  end
  
  it "knows defined methods" do
    introspector.defined_methods.should == [:foo]
  end
  
  it "only observes klass once" do
    introspector.observe_klass!.should be_true
  end
  
  describe "observing a method" do
    context "when the method isn't defined" do
      it "is stored in #observed_methods" do
        introspector.observe(:bar) { }
        introspector.observing?(:bar).should be_true
      end

      it "ceases when method gets defined" do
        introspector.observe(:bar)
        klass.class_eval { def bar; :bar end }
        introspector.observing?(:bar).should be_false
      end
    
      it "allows a callback block for when methods get defined" do
        called = false
        introspector.observe(:bar) { called = true }
        klass.class_eval { def bar; :bar end }
        called.should be_true
      end
    
      it "allows multiple callback blocks" do
        once = twice = false
        introspector.observe(:bar) { once = true }
        introspector.observe(:bar) { twice = true }
        klass.class_eval { def bar; :bar end }
        once.should be_true
        twice.should be_true
      end
    
      it "only runs callbacks once" do
        once = false
        introspector.observe(:bar) { once = !once }
        klass.class_eval { def bar; :bar end }
        klass.class_eval { def bar; :bar end }
        once.should be_true
      end
    end
    
    context "when the method is defined" do
      it "is stored in #observed_methods" do
        introspector.observe(:inspect) { }
        introspector.observing?(:inspect).should be_true
      end

      it "ceases when method gets defined" do
        introspector.observe(:inspect)
        klass.class_eval { def inspect; :inspect end }
        introspector.observing?(:inspect).should be_false
      end
    
      it "allows a callback block for when methods get defined" do
        called = false
        introspector.observe(:inspect) { called = true }
        klass.class_eval { def inspect; :inspect end }
        called.should be_true
      end
    
      it "allows multiple callback blocks" do
        once = twice = false
        introspector.observe(:inspect) { once = true }
        introspector.observe(:inspect) { twice = true }
        klass.class_eval { def inspect; :inspect end }
        once.should be_true
        twice.should be_true
      end
    
      it "only runs callbacks once" do
        once = false
        introspector.observe(:inspect) { once = !once }
        klass.class_eval { def inspect; :inspect end }
        klass.class_eval { def inspect; :inspect end }
        once.should be_true
      end
    end
  end
end