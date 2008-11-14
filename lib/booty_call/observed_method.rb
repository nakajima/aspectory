module BootyCall
  class ObservedMethod
    attr_reader :method_id
    
    def initialize(method_id, options={})
      @method_id = method_id
      @callbacks = []
      @count = 0
      @times = options[:times] || 1
    end
  
    def match(sym)
      return unless case method_id
      when Symbol then valid?
      when Regexp then valid? and method_id.try(:match, sym.to_s)
      else ; nil
      end
      @callbacks.each { |fn| fn.call(sym) }
      @count += 1
    end
    
    def valid?
      @times.to_s.match(/^(inf|any|all|every)/) or @count < @times
    end
  
    def push(*args)
      @callbacks += args
      @callbacks.tap.compact!.uniq!
    end
  end
end