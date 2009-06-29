# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'qtutils'

module AnimationBase
  def to_s
    "#<#{self.class.name}:#{@name}>"
  end
end

class Animation
  include AnimationBase
  
  def initialize(name, &blk)
    @name = name
    @anim = blk
  end
  
  def [](t)
    @anim[t]
  end
end

class SimpleAnimation
  include AnimationBase
  
  def initialize(name, length, before, animation, after = nil)
    @name = name
    @length = length
    @animation = animation
    @before = before
    @after = after
    @start = nil
  end

  def [](t)
    unless @start
      @start = t
      @before[] if @before
    end
    
    i = (t - @start).to_f / @length
    @animation[i]
    if i >= 1.0
      @after[] if @after
      @start = nil
      return true
    end
    
    return false
  end
end


class AnimationField
  def initialize(interval, timer_class = Qt::Timer)
    @actions = []
    @timer = timer_class.every(interval) {|t| tick(t) }
    @ticks = 0
  end
  
  def tick(t)
    @ticks += 1
    @actions.reject! do |action|
      action[t]
    end
  end
  
  def run(action)
    if action
      @actions << action
    end
  end
end
