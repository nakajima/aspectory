require 'spec/spec_helper'

describe BootyCall::Callbacker do
  attr_reader :klass, :callbacker, :object
  
  before(:each) do
    @klass = Class.new do
      attr_reader :results
      
      def initialize
        @results = []
      end
      
      def no
        false
      end
      
      def foo(arg=:foo, &block)
        @results << (block_given? ? block.call : arg)
        arg
      end

      def bar(arg=:bar, &block)
        return arg unless arg
        @results << (block_given? ? block.call : arg)
      end
      
      def is_bar?(arg)
        @results << (arg == :bar)
      end

      def pitch
        throw :foo, :result
      end
    end
    
    @callbacker = BootyCall::Callbacker.new(klass)
    @object = klass.new
  end
  
  describe "klass#__PRISTINE__" do
    it "allows original method calling" do
      callbacker.before(:foo) { @results << :before }
      
      object.__PRISTINE__(:foo)
      object.results.should == [:foo]
    end
    
    it "allows arguments" do
      callbacker.before(:foo) { @results << :before }
      
      object.__PRISTINE__(:foo, :bar)
      object.results.should == [:bar]
    end
    
    it "allows a block" do
      callbacker.before(:foo) { @results << :before }
      
      object.__PRISTINE__(:foo) { :bar }
      object.results.should == [:bar]
    end
    
    it "raises when method doesn't exist" do
      proc {
        callbacker.__PRISTINE__(:whiz)
      }.should raise_error(NoMethodError)
    end
    
    describe "foo_without_callbacks methods" do
      it "are generated for methods with callbacks" do
        callbacker.before(:foo) { @results << :before }

        object.foo_without_callbacks
        object.results.should == [:foo]
      end
    end
  end
  
  describe "#before" do
    context "with a block" do
      it "defines before behavior" do
        callbacker.before(:foo) { @results << :before }

        object.foo
        object.results.should == [:before, :foo]
      end

      describe "redefining methods" do
        it "allows arguments" do
          callbacker.before(:foo) { @results << :before }

          object.foo(:arg)
          object.results.should == [:before, :arg]
        end

        it "allows a block" do
          callbacker.before(:foo) { @results << :before }

          object.foo { :block }
          object.results.should == [:before, :block]
        end

        it "only happens once" do
          mock(callbacker).redefine_method(anything).once
          callbacker.before(:foo) { true }
          callbacker.before(:foo) { false }
        end
      end

      describe "callback blocks" do
        it "enables halting of method call" do
          callbacker.before(:foo) { false }

          object.foo
          object.results.should be_empty
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

        describe "throwing alternative result" do
          before(:each) do
            callbacker.before(:foo) { throw :foo, :result }
          end
          
          it "returns alternative" do
            object.foo.should == :result
          end
          
          it "doesn't run original method" do
            object.results.should be_empty
          end
        end
        
      end
    end
    
    context "with a symbol" do
      it "defines before behavior" do
        callbacker.before(:foo, :bar)

        object.foo
        object.results.should == [:bar, :foo]
      end

      describe "redefining methods" do
        it "allows arguments" do
          callbacker.before(:foo, :bar)

          object.foo(:arg)
          object.results.should == [:bar, :arg]
        end

        it "allows a block" do
          callbacker.before(:foo, :bar)

          object.foo { :block }
          object.results.should == [:bar, :block]
        end
      end

      describe "callback blocks" do
        it "enables halting of method call" do
          callbacker.before(:foo, :no)

          object.foo
          object.results.should be_empty
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
        
        it "doesn't run same callback twice for same method" do
          callbacker.before(:foo, :ping!)
          callbacker.before(:foo, :ping!)
          
          mock(object).ping!.once
          
          object.foo
        end
      end
    end
  end
  
  describe "#after" do
    context "with a block" do
      it "defines after behavior" do
        callbacker.after(:foo) { @results << :after }

        object.foo
        object.results.should == [:foo, :after]
      end

      describe "redefining methods" do
        it "allows arguments" do
          callbacker.after(:foo) { @results << :after }

          object.foo(:arg)
          object.results.should == [:arg, :after]
        end

        it "allows a block" do
          callbacker.after(:foo) { @results << :after }

          object.foo { :block }
          object.results.should == [:block, :after]
        end

        it "only happens once" do
          mock(callbacker).redefine_method(anything).once

          callbacker.after(:bar) { true }
          callbacker.after(:bar) { false }
        end
      end

      describe "callback blocks" do
        it "cannot enable halting of method call" do
          callbacker.after(:foo) { false }

          object.foo
          object.results.should == [:foo]
        end

        it "can be more than one per method" do
          callbacker.after(:foo) { ping! }
          callbacker.after(:foo) { pong! }

          mock(object).ping!
          mock(object).pong!

          object.foo
        end

        it "gets access to result of method call" do
          callbacker.after(:foo) { |result| @results << result }

          object.foo
          object.results.should == [:foo, :foo]
        end

        it "can throw alternative result" do
          callbacker.after(:foo) { throw :foo, :result }

          object.foo.should == :result
        end
      end
    end
    
    context "with a symbol" do
      it "defines after behavior" do
        callbacker.after(:foo, :is_bar?)

        object.foo
        object.results.should == [:foo, false]
      end
      
      it "doesn't run same callback twice for same method" do
        callbacker.after(:foo, :ping!)
        callbacker.after(:foo, :ping!)
        
        mock(object).ping!(anything).once
        
        object.foo
      end

      describe "redefining methods" do
        it "allows arguments" do
          callbacker.after(:foo, :is_bar?)

          object.foo(:bar)
          object.results.should == [:bar, true]
        end

        it "allows a block" do
          callbacker.after(:foo, :bar)

          object.foo { :block }
          object.results.should == [:block, :foo]
        end
      end

      describe "callback blocks" do
        it "cannot enable halting of method call" do
          callbacker.after(:foo, :no)

          object.foo
          object.results.should == [:foo]
        end

        it "gets access to result of method call" do
          callbacker.after(:foo, :bar)

          object.foo(:arg)
          object.results.should == [:arg, :arg]
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