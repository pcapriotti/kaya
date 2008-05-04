class SimpleAnimation
  def initialize(start, length, before, animation, after)
    @start = start
    @length = length
    @animation = animation
    @before = before
    @after = after
    @started = false
  end

  def [](t)
    unless @started
      @started = true
      @before[] if @before
    end
    
    i = (t - @start).to_f / @length
    @animation[i]
    
    if i >= 1.0
      @after[] if @after
      @started = false
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
    @actions << action
  end
end
