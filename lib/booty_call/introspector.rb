module BootyCall
  class Introspector
    attr_reader :klass
    
    def initialize(klass)
      @klass = klass
      @observed_methods = { }
    end
    
    def observe_klass!
      @observed ||= begin
        this = self
        klass.meta_def(:method_added) do |m|
          this.check_method(m)
        end; true
      end
    end
    
    def observing?(method_id)
      not not @observed_methods[method_id]
    end
    
    def observe(method_id, options={}, &block)
      observe_klass!
      @observed_methods[method_id] ||= ObservedMethod.new(method_id, options)
      @observed_methods[method_id].push(block) if block_given?
    end
    
    def defined_methods
      (klass.instance_methods - Object.instance_methods).map(&:to_sym)
    end
    
    def check_method(sym)
      @observed_methods.each do |method_id, observer|
        stop_observing(method_id) do
          observer.match(sym)
          observer.valid?
        end
      end
    end
    
    def stop_observing(method_id, &block)
      @observed_methods.delete(method_id).tap do |observer|
        @observed_methods[method_id] = observer if block.try(:call, observer)
      end
    end
  end
end