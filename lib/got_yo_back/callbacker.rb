module GotYoBack
  class Callbacker
    attr_reader :klass
    
    def initialize(klass)
      @klass = klass
    end
    
    def before(method_id, &block)
      klass.class_eval do
        instance = instance_method(method_id)
        define_method(method_id) do |*args|
          instance.bind(self).call(*args) if instance_eval(&block)
        end
      end
    end
  end
end