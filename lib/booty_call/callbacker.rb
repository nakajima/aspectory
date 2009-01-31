module BootyCall
  class Callbacker
    attr_reader :klass
    
    def initialize(klass)
      @klass = klass
      extend_klass
    end
    
    def before(method_id, *symbols, &block)
      add_callback(:before, method_id, *symbols, &block)
    end
    
    def after(method_id, *symbols, &block)
      add_callback(:after, method_id, *symbols, &block)
    end
    
    def around(method_id, *symbols, &block)
      add_callback(:around, method_id, *symbols, &block)
    end
    
    private
    
    def extend_klass
      klass.class_eval do
        @pristine_cache = Hash.new
        @callback_cache = { :after => Hash.new([]), :before => Hash.new([]), :around => Hash.new([]) }
        extend ClassMethods
        include InstanceMethods
      end
    end
    
    def add_callback(position, method_id, *symbols, &block)
      klass.callback_cache[position][method_id] << block if block_given?
      klass.callback_cache[position][method_id] += symbols
      klass.callback_cache[position][method_id].compact!
      klass.callback_cache[position][method_id].uniq!
      
      klass.pristine_cache[method_id] ||= begin
        klass.instance_method(method_id).tap do
          redefine_method method_id
        end
      end
    end
    
    def redefine_method(method_id)
      safe_method_id = method_id.to_s
      safe_method_id.gsub!(/([\w_]+)(\?|!|=|\b)/) { |m| "#{$1}_without_callbacks#{$2}" }
      klass.class_eval(<<-EOS, "(__DELEGATION__)", 1)
        def #{method_id}(*args, &block)
          catch(#{method_id.to_sym.inspect}) do
            res = nil
            run_callbacks(:before, #{method_id.inspect})
            run_callbacks(:around, #{method_id.inspect}) { res = __PRISTINE__(#{method_id.inspect}, *args, &block) }
            run_callbacks(:after,  #{method_id.inspect}, res)
            res
          end
        end
        
        def #{safe_method_id}(*args, &block)
          __PRISTINE__(#{method_id.inspect}, *args, &block)
        end
      EOS
    end
    
    module ClassMethods
      def pristine_cache
        @pristine_cache || superclass.pristine_cache
      end
      
      def callback_cache
        @callback_cache || superclass.callback_cache
      end
    end
    
    module InstanceMethods
      def callbacks_for(position, method_id, *results, &block)
        callbacks = self.class.callback_cache[position][method_id.to_sym]
        
        if callbacks.empty?
          block ? instance_eval(&block) : true
        else
          callbacks.map { |callback|
            if callback.is_a?(Proc)
              instance_exec(*results.enqueue(block), &callback)
            else
              method(callback).arity_match?(results) ?
                send(callback, *results, &block) :
                send(callback, &block)
            end
          }.all?
        end
      end
      
      def run_callbacks(position, method_id, *args, &block)
        callbacks_for(position, method_id, *args, &block).tap do |result|
          # Halt method propagation if before callbacks return false
          throw(method_id, false) if position.eql?(:before) and result.eql?(false)
        end
      end
      
      def __PRISTINE__(method_id, *args, &block)
        if method = self.class.pristine_cache[method_id]
          method.bind(self).call(*args, &block)
        else
          raise NoMethodError, "No method named #{method_id.inspect}"
        end
      end
    end
  end
end