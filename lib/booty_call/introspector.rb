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
          this.send(:check_method, m)
        end; true
      end
    end
    
    def observing?(method_id)
      not not @observed_methods[method_id]
    end
    
    def observe(method_id, &block)
      observe_klass!
      @observed_methods[method_id] ||= []
      @observed_methods[method_id].tap do |set|
        set.push(block) if block_given?
        set.tap.compact!.uniq!
      end
    end
    
    def defined_methods
      (klass.instance_methods - Object.instance_methods).map(&:to_sym)
    end
    
    private
    
    def check_method(sym)
      @observed_methods.each do |method_id, handlers|
        handlers.each(&:call) if method_match?(sym, method_id)
      end
    end
    
    def method_match?(sym, method_id)
      case method_id
      when Symbol then @observed_methods.delete(method_id)
      when Regexp then @observed_methods.delete(method_id) and sym.to_s.match(method_id)
      else ; nil
      end
    end
  end
end