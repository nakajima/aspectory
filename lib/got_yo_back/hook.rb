module GotYoBack
  module Hook
    def self.included(klass)
      klass.class_eval do
        extend(ClassMethods)
        @callbacker = GotYoBack::Callbacker.new(self)
        @introspector = GotYoBack::Introspector.new(self)
      end
    end
    
    module ClassMethods
      def before(method_id, *args, &block)
        callback(:before, method_id, *args, &block)
      end
      
      def after(method_id, *args, &block)
        callback(:after, method_id, *args, &block)
      end
      
      def observe(method_id, &block)
        @introspector.observe(method_id, &block)
      end
      
      def callback(position, method_id, *args, &block)
        @introspector.defined_methods.include?(method_id) ?
          @callbacker.send(position, method_id, *args, &block) :
          observe(method_id) { send(position, method_id, *args, &block) }
      end
    end
  end
end