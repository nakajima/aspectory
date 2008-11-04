module GotYoBack
  module Hook
    def self.included(klass)
      klass.class_eval do
        meta_eval { attr_reader :_callbacker, :_introspector }
        
        @_callbacker   = GotYoBack::Callbacker.new(self)
        @_introspector = GotYoBack::Introspector.new(self)
        
        extend(ClassMethods)
      end
    end
    
    module ClassMethods
      def before(method_id, *args, &block)
        callback :before, method_id, *args, &block
      end
      
      def after(method_id, *args, &block)
        callback :after, method_id, *args, &block
      end
      
      def callback(position, method_id, *args, &block)
        if _introspector.defined_methods.include?(method_id)
          _callbacker.send(position, method_id, *args, &block)
        else
          _introspector.observe(method_id) { send(position, method_id, *args, &block) }
        end
      end
    end
  end
end