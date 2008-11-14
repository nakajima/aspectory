module BootyCall
  class ObservedMethod
    attr_reader :method_id
    
    def initialize(method_id, options={})
      @method_id = method_id
      @handlers = []
      @count = 0
      @times = options[:times] || 1
    end
  
    def match(sym)
      return unless case method_id
      when Symbol then valid?
      when Regexp then valid? and method_id.try(:match, sym.to_s)
      else ; nil
      end
      @handlers.each { |fn| fn[sym] }
      @count += 1
    end
    
    def valid?
      if @times.to_s.match(/^(inf|any|all|every)/)
        def self.valid?; true end
        true # memoizing the result
      else
        @count < @times
      end
    end
  
    def push(*args)
      @handlers += args
      @handlers.tap.compact!.uniq!
    end
  end
end