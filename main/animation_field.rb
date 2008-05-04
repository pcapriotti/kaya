class SimpleAnimation
  def initialize(length, before, animation, after = nil)
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
    if i >= 1.0
      @after[] if @after
      @start = nil
      return true
    end
    
    @animation[i]
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
