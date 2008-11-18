module BootyCall
  def self.included(klass)
    klass.send(:include, Hook)
  end
  
  module Hook
    def self.included(klass)
      klass.class_eval do
        extend(ClassMethods)
        @callbacker = BootyCall::Callbacker.new(self)
        @introspector = BootyCall::Introspector.new(self)
        @meta_introspector = BootyCall::Introspector.new(self, :meta => true)
      end
    end
    
    module ClassMethods
      def before(method_id, *args, &block)
        callback(:before, method_id, *args, &block)
      end
      
      def after(method_id, *args, &block)
        callback(:after, method_id, *args, &block)
      end
      
      def around(method_id, *args, &block)
        callback(:around, method_id, *args, &block)
      end
      
      def observe(method_id, options={}, &block)
        observer = options[:meta] ? @meta_introspector : @introspector
        observer.observe(method_id, options, &block)
      end
      
      def callback(position, method_id, *args, &block)
        case method_id
        when Regexp
          observe(method_id, :times => :all) { |m| send(position, m, *args, &block) }
          @introspector.defined_methods.map(&:to_s).each do |m|
            next unless m =~ method_id
            callback(position, m.to_sym, *args, &block) 
          end
        when Symbol
          @introspector.has_method?(method_id) ?
            @callbacker.send(position, method_id, *args, &block) :
            observe(method_id) { send(position, method_id, *args, &block) }
        end
      end
    end
  end
end