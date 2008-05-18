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
  def initialize(interval)
    @actions = []
    Qt::Timer.every(interval) {|t| tick(t) }
  end
  
  def tick(t)
    @actions.reject! do |action|
      action[t]
    end
  end
  
  def run(action)
    @actions << action if action
  end
end
