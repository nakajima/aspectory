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
    mock(klass).meta_def(:method_added).once
    introspector.observe_klass!
    introspector.observe_klass!
  end
  
  describe "observing a method" do
    context "on a metaclass" do
      attr_reader :meta_introspector
      
      before(:each) do
        @meta_introspector = BootyCall::Introspector.new(klass, :meta => true)
      end
      
      it "is stored in #observed_methods" do
        meta_introspector.observe(:bar) { }
        meta_introspector.observing?(:bar).should be_true
      end

      it "ceases when method gets defined" do
        meta_introspector.observe(:bar)
        klass.class_eval { def self.bar; :bar end }
        meta_introspector.observing?(:bar).should be_false
      end
    
      it "allows a callback block for when methods get defined" do
        called = false
        meta_introspector.observe(:bar) { called = true }
        klass.class_eval { def self.bar; :bar end }
        called.should be_true
      end
    
      it "allows multiple callback blocks" do
        once = twice = false
        meta_introspector.observe(:bar) { once = true }
        meta_introspector.observe(:bar) { twice = true }
        klass.class_eval { def self.bar; :bar end }
        once.should be_true
        twice.should be_true
      end
    end
    
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
      
      describe "specifying limits" do
        it "allows a :times option" do
          mock(callee = Object.new).call!
          introspector.observe(:bar, :times => 1) { callee.call! }
          klass.class_eval { def bar; :bar end }
          klass.class_eval { def bar; :bar end }
        end
        
        it "allows callback to be run 2 times" do
          mock(callee = Object.new).call!.times(2)
          introspector.observe(:bar, :times => 2) { callee.call! }
          klass.class_eval { def bar; :bar end }
          klass.class_eval { def bar; :bar end }
          klass.class_eval { def bar; :bar end }
        end
        
        it "allows callback to be run 3 times" do
          mock(callee = Object.new).call!.times(3)
          introspector.observe(:bar, :times => 3) { callee.call! }
          klass.class_eval { def bar; :bar end }
          klass.class_eval { def bar; :bar end }
          klass.class_eval { def bar; :bar end }
          klass.class_eval { def bar; :bar end }
        end
        
        it "allows callback to be run every time" do
          mock(callee = Object.new).call!.times(3)
          introspector.observe(:bar, :times => :infinite) { callee.call! }
          klass.class_eval { def bar; :bar end }
          klass.class_eval { def bar; :bar end }
          klass.class_eval { def bar; :bar end }
        end
        
        it "should works with other times terms abbreviation" do
          mock(callee = Object.new).call!.times(3)
          introspector.observe(:bar, :times => :any) { callee.call! }
          klass.class_eval { def bar; :bar end }
          klass.class_eval { def bar; :bar end }
          klass.class_eval { def bar; :bar end }
        end
        
        it "should works with :all abbreviation" do
          mock(callee = Object.new).call!.times(3)
          introspector.observe(:bar, :times => :all) { callee.call! }
          klass.class_eval { def bar; :bar end }
          klass.class_eval { def bar; :bar end }
          klass.class_eval { def bar; :bar end }
        end
        
        it "should works with :every abbreviation" do
          mock(callee = Object.new).call!.times(3)
          introspector.observe(:bar, :times => :every) { callee.call! }
          klass.class_eval { def bar; :bar end }
          klass.class_eval { def bar; :bar end }
          klass.class_eval { def bar; :bar end }
        end
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
  
  describe "observing a regex" do
    context "when the method isn't defined" do
      it "is stored in #observed_methods" do
        introspector.observe(/(foo|bar)/) { }
        introspector.observing?(/(foo|bar)/).should be_true
      end

      it "ceases when a matching method gets defined" do
        introspector.observe(/(foo|bar)/)
        klass.class_eval { def bar; :bar end }
        introspector.observing?(/(foo|bar)/).should be_false
      end
    
      it "allows a callback block for when methods get defined" do
        called = false
        introspector.observe(/(foo|bar)/) { called = true }
        klass.class_eval { def bar; :bar end }
        called.should be_true
      end
    
      it "allows multiple callback blocks" do
        once = twice = false
        introspector.observe(/(bar)/) { once = true }
        introspector.observe(/(foo|bar)/) { twice = true }
        klass.class_eval { def bar; :bar end }
        once.should be_true
        twice.should be_true
      end
      
      it "passes the method name" do
        called = false
        introspector.observe(/(foo|bar)/) { |method_id| called = method_id.eql?(:bar) }
        klass.class_eval { def bar; :bar end }
        called.should be_true
      end
    
      it "only runs callbacks once" do
        once = false
        introspector.observe(/(foo|bar)/) { once = !once }
        klass.class_eval { def foo; :foo end }
        klass.class_eval { def bar; :bar end }
        once.should be_true
      end
    end
    
    context "when the method is defined" do
      it "is stored in #observed_methods" do
        introspector.observe(/inspect/) { }
        introspector.observing?(/inspect/).should be_true
      end
    
      it "ceases when method gets defined" do
        introspector.observe(/inspect/)
        klass.class_eval { def inspect; :inspect end }
        introspector.observing?(/inspect/).should be_false
      end
    
      it "allows a callback block for when methods get defined" do
        called = false
        introspector.observe(/inspect/) { called = true }
        klass.class_eval { def inspect; :inspect end }
        called.should be_true
      end
    
      it "allows multiple callback blocks" do
        once = twice = false
        introspector.observe(/inspect/) { once = true }
        introspector.observe(/inspect/) { twice = true }
        klass.class_eval { def inspect; :inspect end }
        once.should be_true
        twice.should be_true
      end
    
      it "only runs callbacks once" do
        once = false
        introspector.observe(/inspect/) { once = !once }
        klass.class_eval { def inspect; :inspect end }
        klass.class_eval { def inspect; :inspect end }
        once.should be_true
      end
    end
  end
end