module BootyCall
  module Hook
    def self.included(klass)
      klass.class_eval do
        extend(ClassMethods)
        @callbacker = BootyCall::Callbacker.new(self)
        @introspector = BootyCall::Introspector.new(self)
        @meta_introspector = BootyCall::Introspector.new(self, :meta => true)
      end
    end
    
    module ClassMethods
      def before(method_id, *args, &block)
        callback(:before, method_id, *args, &block)
      end
      
      def after(method_id, *args, &block)
        callback(:after, method_id, *args, &block)
      end
      
      def observe(method_id, options={}, &block)
        observer = options[:meta] ? @meta_introspector : @introspector
        observer.observe(method_id, options, &block)
      end
      
      def callback(position, method_id, *args, &block)
        @introspector.defined_methods.include?(method_id) ?
          @callbacker.send(position, method_id, *args, &block) :
          observe(method_id) { send(position, method_id, *args, &block) }
      end
    end
  end
end