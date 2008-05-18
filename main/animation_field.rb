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

class AnimationField < Qt::Object
  def initialize(interval)
    super(nil)
    
    @time = Qt::Time.new
    @timer = Qt::Timer.new
    
    connect(@timer, SIGNAL('timeout()'), self, SLOT('tick()'))
    
    @time.restart
    @timer.start(interval)
    @actions = []
  end
  
  def tick
    @actions.reject! do |action|
      action[@time.elapsed]
    end
  end
  slots 'tick()'
  
  def run(action)
    @actions << action if action
  end
end
