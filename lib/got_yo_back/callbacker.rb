module GotYoBack
  class Callbacker
    attr_reader :klass
    
    METHOD_DEF = proc do |method_id|
      
    end
    
    def initialize(klass)
      @klass = klass
      extend_klass
    end
    
    def extend_klass
      klass.extend(ClassMethods)
      klass.send :include, InstanceMethods
    end
    
    def before(method_id, &block)
      add_callback(:before, method_id, &block)
    end
    
    private
    
    def add_callback(position, method_id, &block)
      klass.class_eval do
        callback_cache[position][method_id] << block
        pristine_cache[method_id] ||= begin
          pristine_method = instance_method(method_id)
          redefine_method method_id
          pristine_method
        end
      end
    end
    
    module ClassMethods
      def pristine_cache
        @pristine_cache ||= Hash.new
      end
      
      def callback_cache
        @callback_cache ||= Hash.new(Hash.new([]))
      end
      
      def run_callbacks_for(target, position, method_id)
        callback_cache[position][method_id].map { |fn| target.instance_eval(&fn) }.all?
      end
      
      def redefine_method(method_id)
        return if pristine_cache[method_id]
        class_eval(<<-EOS, "(__DELEGATION__)", 1)
          def #{method_id}(*args, &block)
            return unless self.class.run_callbacks_for(self, :before, #{method_id.inspect})
            pristine(#{method_id.inspect}, *args, &block)
          end
        EOS
      end
    end
    
    module InstanceMethods
      def pristine(method_id, *args, &block)
        if method = self.class.pristine_cache[method_id]
          method.bind(self).call *args, &block
        else
          raise NoMethodError, "No method named #{method_id.inspect}"
        end
      end
    end
  end
end