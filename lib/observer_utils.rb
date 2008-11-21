require 'observer'

module Observer
  def update(data)
    data.each_key do |key|
      m = begin
        method("on_#{key}")
      rescue NameError
      end
      
      if m
        case m.arity
        when 0
          m[]
        when 1
          m[data[key]]
        else
          m[*data[key]]
        end
      end
    end
  end
end

module Observable
  def observe(event, &blk)
    add_observer SimpleObserver.new(event, &blk)
  end

  def fire(events)
    changed
    if events.is_a? Symbol
      events = { events => nil }
    end
    notify_observers events
  end
end

class SimpleObserver
  include Observer
  
  def initialize(event, &blk)
    metaclass_eval do
      define_method "on_#{event}", &blk
    end
  end
end

class Object
  def metaclass
    class << self
      self
    end
  end
  
  def metaclass_eval(&blk)
    metaclass.instance_eval(&blk)
  end
end
