module GotYoBack
  class Introspector
    attr_reader :klass
    
    def initialize(klass)
      @klass = klass
      @observed_methods = Hash.new
    end
    
    def observe_klass!
      @observed ||= begin
        this = self
        @klass.meta_def(:method_added) do |m|
          this.check_method(m)
        end and true
      end
    end
    
    def observing?(method_id)
      not not @observed_methods[method_id]
    end
    
    def observe(method_id, &block)
      observe_klass!
      @observed_methods[method_id] = block || proc { }
    end
    
    def check_method(method_id)
      @observed_methods.delete(method_id).call rescue nil
    end
    
    def defined_methods
      (klass.instance_methods - Object.instance_methods).map(&:to_sym)
    end
  end
end