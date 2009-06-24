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

  def fire(e)
    changed
    notify_observers any_to_event(e)
  end
  
  def any_to_event(e)
    if e.is_a? Symbol
      { e => nil }
    else
      e
    end
  end
end

class SimpleObserver
  def initialize(event, &blk)
    @event = event
    @blk = blk
  end
  
  def update(data)
    if data.has_key?(@event)
      case @blk.arity
      when 0
        @blk[]
      when 1
        @blk[data[@event]]
      else
        @blk[*data[@event]]
      end
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
