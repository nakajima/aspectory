require 'spec/spec_helper'

describe GotYoBack::Callbacker do
  attr_reader :klass, :callbacker, :object
  
  before(:each) do
    @klass = Class.new do
      def no; false end
      def foo; :foo end
      def bar; @called = true end
      def fizz(arg=false); @called = arg end
      def buzz; @called = yield end
      def called?; @called end
      def pitch; throw :foo, :result end
    end
    
    @callbacker = GotYoBack::Callbacker.new(klass)
    @object = klass.new
  end
  
  describe "klass#pristine" do
    it "allows original method calling" do
      callbacker.before(:foo) { @called = true }
      
      object.pristine(:foo)
      object.should_not be_called
    end
    
    it "allows arguments" do
      callbacker.before(:fizz) { :ok }
      
      object.pristine :fizz, true
      object.should be_called
    end
    
    it "allows a block" do
      callbacker.before(:buzz) { :ok }
      
      object.pristine(:buzz) { true }
      object.should be_called
    end
  end
  
  describe "#before" do
    context "with a block" do
      it "defines before behavior" do
        callbacker.before(:foo) { @called = true }

        object.foo
        object.should be_called
      end

      it "still performs original behavior" do
        callbacker.before(:bar) { :ok }

        object.bar
        object.should be_called
      end

      describe "redefining methods" do
        it "allows arguments" do
          callbacker.before(:fizz) { :ok }

          object.fizz(true)
          object.should be_called
        end

        it "allows a block" do
          callbacker.before(:buzz) { :ok }

          object.buzz { true }
          object.should be_called
        end

        it "only happens once" do
          mock(callbacker).redefine_method(anything).once
          callbacker.before(:bar) { true }
          callbacker.before(:bar) { false }
        end
      end

      describe "callback blocks" do
        it "enables halting of method call" do
          callbacker.before(:bar) { false }

          object.bar
          object.should_not be_called
        end

        it "can be more than one per method" do
          callbacker.before(:foo) { ping! }
          callbacker.before(:foo) { pong! }

          mock(object) do |expect|
            expect.ping!
            expect.pong!
          end

          object.foo
        end

        it "can throw alternative result" do
          callbacker.before(:foo) { throw :foo, :result }

          object.foo.should == :result
        end
      end
    end
    
    context "with a symbol" do
      it "defines before behavior" do
        callbacker.before(:foo, :bar)

        object.foo
        object.should be_called
      end

      it "still performs original behavior" do
        callbacker.before(:bar, :foo)

        object.bar
        object.should be_called
      end

      describe "redefining methods" do
        it "allows arguments" do
          callbacker.before(:fizz, :foo)

          object.fizz(true)
          object.should be_called
        end

        it "allows a block" do
          callbacker.before(:buzz, :foo)

          object.buzz { true }
          object.should be_called
        end
      end

      describe "callback blocks" do
        it "enables halting of method call" do
          callbacker.before(:bar, :no)

          object.bar
          object.should_not be_called
        end

        it "can be more than one per method" do
          callbacker.before(:foo, :ping!)
          callbacker.before(:foo, :pong!)

          mock(object) do |expect|
            expect.ping!
            expect.pong!
          end

          object.foo
        end
      end
    end
  end
  
  describe "#after" do
    context "with a block" do
      it "defines after behavior" do
        callbacker.after(:foo) { @called = true }

        object.should_not be_called
        object.foo
        object.should be_called
      end

      it "still performs original behavior" do
        callbacker.after(:bar) { :ok }

        object.bar
        object.should be_called
      end

      describe "redefining methods" do
        it "allows arguments" do
          callbacker.after(:fizz) { :ok }

          object.fizz(true)
          object.should be_called
        end

        it "allows a block" do
          callbacker.after(:buzz) { :ok }

          object.buzz { true }
          object.should be_called
        end

        it "only happens once" do
          mock(callbacker).redefine_method(anything).once

          callbacker.after(:bar) { true }
          callbacker.after(:bar) { false }
        end
      end

      describe "callback blocks" do
        it "cannot enable halting of method call" do
          callbacker.after(:bar) { false }

          object.bar
          object.should be_called
        end

        it "can be more than one per method" do
          callbacker.after(:foo) { ping! }
          callbacker.after(:foo) { pong! }

          mock(object).ping!
          mock(object).pong!

          object.foo
        end

        it "gets access to result of method call" do
          callbacker.after(:foo) { |result| @called = result }

          object.should_not be_called
          object.foo
          object.should be_called
        end

        it "can throw alternative result" do
          callbacker.after(:foo) { throw :foo, :result }

          object.foo.should == :result
        end
      end
    end
    
    context "with a symbol" do
      it "defines after behavior" do
        callbacker.after(:foo, :bar)

        object.should_not be_called
        object.foo
        object.should be_called
      end

      it "still performs original behavior" do
        callbacker.after(:bar, :foo)
        
        object.should_not be_called
        object.bar
        object.should be_called
      end

      describe "redefining methods" do
        it "allows arguments" do
          callbacker.after(:fizz, :foo)

          object.fizz(true)
          object.should be_called
        end

        it "allows a block" do
          callbacker.after(:buzz, :foo)

          object.buzz { true }
          object.should be_called
        end
      end

      describe "callback blocks" do
        it "cannot enable halting of method call" do
          callbacker.after(:bar, :no)

          object.bar
          object.should be_called
        end

        it "gets access to result of method call" do
          callbacker.after(:foo, :fizz)

          object.should_not be_called
          object.foo
          object.should be_called
        end
        
        it "can be more than one per method" do
          callbacker.after(:foo, :ping!)
          callbacker.after(:foo, :pong!)

          mock(object).ping!.with(:foo)
          mock(object).pong!.with(:foo)

          object.foo
        end

        it "can throw alternative result" do
          callbacker.after(:foo, :pitch)

          object.foo.should == :result
        end
      end
    end
  end
end