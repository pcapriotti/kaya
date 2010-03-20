# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'observer'
require 'utils'

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
  def on(event, &blk)
    observe(event, &blk)
  end
  
  def observe(event, &blk)
    obs = SimpleObserver.new(event, &blk)
    add_observer obs
    # return observer so that we can remove it later
    obs
  end
  
  def observe_limited(event, &blk)
    obs = LimitedObserver.new(self, event, &blk)
    add_observer obs
    obs
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

class Proc
  def generic_call(args)
    case arity
    when 0
      call
    when 1
      call(args)
    else
      call(*args)
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
      @blk.generic_call(data[@event])
    end
  end
end

class LimitedObserver < SimpleObserver
  def initialize(observed, event, &blk)
    super(event, &blk)
    @observed = observed
  end
  
  def update(data)
    remove = super(data)
    @observed.delete_observer(self) if remove
    remove
  end
end
