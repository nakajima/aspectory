module GotYoBack
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
    
    private
    
    def extend_klass
      klass.class_eval do
        meta_eval { attr_reader :pristine_cache, :callback_cache }
        @pristine_cache = Hash.new
        @callback_cache = { :after => Hash.new([]), :before => Hash.new([]) }
        extend ClassMethods
        include InstanceMethods
      end
    end
    
    def add_callback(position, method_id, *symbols, &block)
      klass.callback_cache[position][method_id] += symbols
      klass.callback_cache[position][method_id] << block
      klass.callback_cache[position][method_id].compact!
      klass.pristine_cache[method_id] ||= begin
        pristine_method = klass.instance_method(method_id)
        redefine_method method_id
        pristine_method
      end
    end
    
    def redefine_method(method_id)
      return if klass.pristine_cache[method_id]
      klass.class_eval(<<-EOS, "(__DELEGATION__)", 1)
        def #{method_id}(*args, &block)
          catch(#{method_id.to_sym.inspect}) do
            return unless self.class.run_callbacks_for(self, :before, #{method_id.inspect})
            result = pristine(#{method_id.inspect}, *args, &block)
            self.class.run_callbacks_for(self, :after, #{method_id.inspect}, result)
            return result
          end
        end
      EOS
    end
    
    module ClassMethods
      def run_callbacks_for(target, position, method_id, *results)
        callbacks = callback_cache[position][method_id.to_sym]
        
        handler = proc do |fn|
          fn.is_a?(Proc) ? fn : begin
            target.method(fn).arity.abs == results.length ?
              proc { send(fn, *results) } :
              proc { send(fn) }
          end
        end
        
        callbacks.empty? ? true : callbacks.map { |fn|
          target.instance_exec(*results, &handler.call(fn))
        }.all? { |result| !!result }
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