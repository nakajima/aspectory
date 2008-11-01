module GotYoBack
  class Callbacker
    attr_reader :klass
    
    def initialize(klass)
      @klass = klass
      extend_klass
    end
    
    def extend_klass
      klass.class_eval do
        @@pristine_cache = { }
        
        def pristine(method_id, *args, &block)
          if method = @@pristine_cache[method_id]
            method.bind(self).call *args, &block
          else
            raise NoMethodError, "No method named #{method_id.inspect}"
          end
        end
      end
    end
    
    def before(method_id, &block)
      klass.class_eval do
        @@pristine_cache[method_id] ||= instance_method(method_id)
        define_method(method_id) do |*args|
          pristine(method_id, *args) if instance_eval(&block)
        end
      end
    end
  end
end