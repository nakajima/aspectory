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
    
    private
    
    def extend_klass
      klass.class_eval do
        @pristine_cache = Hash.new
        @callback_cache = { :after => Hash.new([]), :before => Hash.new([]) }
        extend ClassMethods
        include InstanceMethods
      end
    end
    
    def add_callback(position, method_id, *symbols, &block)
      klass.callback_cache[position][method_id].tap do |slot|
        slot.push(block) if block_given?
        slot.concat(symbols)
        slot.tap.compact!.uniq!
      end
      
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
            return unless self.class.run_callbacks_for(self, :before, #{method_id.inspect})
            __PRISTINE__(#{method_id.inspect}, *args, &block).tap do |result|
              self.class.run_callbacks_for(self, :after, #{method_id.inspect}, result)
            end
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
      
      def run_callbacks_for(target, position, method_id, *results)
        callbacks = callback_cache[position][method_id.to_sym]
        
        handle = proc do |fn|
          target.method(fn).arity.abs == results.length ?
            proc { send(fn, *results) } :
            proc { send(fn) }
        end
        
        callbacks.empty? ? true : callbacks.map { |fn|
          target.instance_exec(*results, &(fn.is_a?(Proc) ? fn : handle[fn]))
        }.all?
      end
    end
    
    module InstanceMethods
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