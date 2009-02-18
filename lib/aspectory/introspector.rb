module Aspectory
  class Introspector
    attr_reader :klass, :options
    
    def initialize(klass, options={})
      @klass, @options = klass, options
      @observed_methods = { }
    end
    
    def observe(method_id, options={}, &block)
      observe_klass!
      @observed_methods[method_id] ||= ObservedMethod.new(method_id, options)
      @observed_methods[method_id].push(block) if block_given?
    end
    
    def observe_klass!
      @observed ||= begin
        name = options[:meta] ? :singleton_method_added : :method_added
        install_hook(name) or true
      end
    end
    
    def defined_methods
      (klass.instance_methods - Object.instance_methods).map(&:to_sym)
    end
    
    def has_method?(method_id)
      klass.instance_method(method_id) rescue false
    end
    
    def observing?(method_id)
      not not @observed_methods[method_id]
    end
    
    private
    
    def install_hook(name)
      this = self
      klass.meta_def(name) do |m|
        this.send :check_method, m
      end
    end

    def check_method(sym)
      @observed_methods.each do |method_id, observer|
        without_observers(method_id) do
          observer.match(sym)
          observer.valid?
        end
      end
    end
    
    def without_observers(method_id, &block)
      @observed_methods.delete(method_id).tap do |observer|
        @observed_methods[method_id] = observer if block[observer]
      end
    end
  end
end