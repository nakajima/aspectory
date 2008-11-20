require 'spec/spec_helper'

describe BootyCall::Hook do
  attr_reader :klass, :object
  
  before(:each) do
    @klass = Class.new do
      include BootyCall
      
      after :bar, :call!
      before :foo, :call!
      around(:fizz) { |fn| call!; fn.call }
      callback :before, :fizz, :call!
      
      def foo; :foo end
      def bar; :bar end
      def fizz; :fizz end
      def buzz; :buzz end
      def call!; @called = true end
      def called?; @called end
      def round(fn); @called = fn.call end
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
    
    it "allows regex declarations of callback behavior for defined methods" do
      klass.class_eval { before(/foo|bar/, :regexd!) }
      mock(object).regexd!.twice
      object.foo
      object.bar
    end
    
    it "allows regex declarations of callback behavior for undefined methods" do
      klass.before(/ping/) { pinged! } #, :pinged!)
      klass.before(/pong/) { ponged! }
      
      klass.class_eval do
        def ping; :ping end
        def pong; :pong end
        def pung; :pung end
      end
      
      mock(object).pinged!
      mock(object).ponged!
      mock(object).call!.never
      object.ping
      object.pong
    end
  end
  
  describe "#after" do
    it "allows callbacks to be defined before methods are" do
      object.should_not be_called
      object.bar
      object.should be_called
    end

    it "allows callbacks to be defined after methods are" do
      klass.after(:buzz, :call!)

      object.should_not be_called
      object.buzz
      object.should be_called
    end
    
    it "allows regex declarations of callback behavior for defined methods" do
      klass.class_eval { after(/foo|bar/, :regexd!) }
      mock(object).regexd!(:foo)
      mock(object).regexd!(:bar)
      object.foo
      object.bar
    end
    
    it "allows regex declarations of callback behavior for undefined methods" do
      klass.class_eval { after(/ping|pong/, :regexd!) }
      
      klass.class_eval { def ping; :ping end }
      klass.class_eval { def pong; :pong end }
      
      mock(object).regexd!(:ping)
      mock(object).regexd!(:pong)
      object.ping
      object.pong
    end
    
    it "allows regex declarations of callback behavior for undefined methods" do
      klass.after(/ping/) { pinged! } #, :pinged!)
      klass.after(/pong/) { ponged! }
      
      klass.class_eval do
        def ping; :ping end
        def pong; :pong end
        def pung; :pung end
      end
      
      mock(object).pinged!
      mock(object).ponged!
      mock(object).call!.never
      object.ping
      object.pong
    end
  end
  
  describe "#around" do
    it "allows callbacks to be defined before methods are" do
      object.should_not be_called
      object.fizz.should == :fizz
      object.should be_called
    end
  
    it "allows callbacks to be defined after methods are" do
      klass.around(:buzz) { |fn| call!; fn.call }
  
      object.should_not be_called
      object.buzz
      object.should be_called
    end
    
    it "allows regex declarations of callback behavior for defined methods" do
      klass.class_eval do
        around(/foo|bar/) { |f| regexd! f.call }
      end
      mock(object).regexd!(:foo)
      mock(object).regexd!(:bar)
      object.foo
      object.bar
    end
    
    it "allows regex declarations of callback behavior for undefined methods" do
      klass.class_eval do
        around(/ping|pong/) { |f| regexd! f.call }
      end
      
      klass.class_eval { def ping; :ping end }
      klass.class_eval { def pong; :pong end }
      
      mock(object).regexd!(:ping)
      mock(object).regexd!(:pong)
      object.ping
      object.pong
    end
    
    it "allows regex declarations of callback behavior for undefined methods" do
      klass.around(/ping/) { |fn| fn.call pinged! } #, :pinged!)
      klass.around(/pong/) { |fn| fn.call ponged! }
      
      klass.class_eval do
        def ping; :ping end
        def pong; :pong end
        def pung; :pung end
      end
      
      mock(object).pinged!
      mock(object).ponged!
      mock(object).call!.never
      object.ping
      object.pong
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
  
  describe "#observe" do
    it "allows method definitions to be observed" do
      called = false
      klass.observe(:boom) { called = true }
      klass.class_eval { def boom; :boom end }
      called.should be_true
    end
    
    it "allows multiple callbacks for observed methods" do
      once = twice = false
      klass.observe(:boom) { once = true }
      klass.observe(:boom) { twice = true }
      klass.class_eval { def boom; :boom end }
      once.should be_true
      twice.should be_true
    end
    
    it "only runs callbacks once by default" do
      called = false
      klass.observe(:boom) { called = !called }
      klass.class_eval { def boom; :boom end }
      klass.class_eval { def boom; :boom end }
      called.should be_true
    end
    
    it "allows callback limits to be specified" do
      mock(callee = Object.new).call!.times(3)
      klass.observe(:foo, :times => 3) { callee.call! }
      klass.class_eval { def foo; :foo end }
      klass.class_eval { def foo; :foo end }
      klass.class_eval { def foo; :foo end }
      klass.class_eval { def foo; :foo end }
    end
    
    it "should allows metaclasses to be observed" do
      mock(callee = Object.new).call!
      klass.observe(:foo, :meta => true) { callee.call! }
      klass.class_eval { def self.foo; :foo end }
    end
  end
end