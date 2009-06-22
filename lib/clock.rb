class Clock
  include Observable
  ByoYomi = Struct.new(:time, :periods)

  # main = allotted time
  # increment = increment per move
  # byoyomi.time = time per move after main is elapsed
  # byoyomi.periods = number of times byoyomi.time has to elapse
  #                   for the byoyomi to end
  #                   
  # byoyomi and increment don't work together
  #                   
  # all times are in seconds
  # 
  def initialize(main, increment, byoyomi, timer_class = Qt::Timer)
    @main = main
    @increment = increment
    if byoyomi
      @byoyomi = byoyomi.dup
      @byoyomi_time = @byoyomi.time
    end
    
    @timer = timer_class.new
    @timer.single_shot = true
    @timer.on(:timeout) { tick }
  end
  
  def start
    @count = 0
    @elapsed = 0
    @time = Qt::Time.new
    
    @time.start
    @timer.start(100)
  end
  
  def stop
    @elapsed += @time.elapsed
    @timer.stop
    
    @main += @increment
    
    fire :timer => { :main => @main }
  end
  
  def resume
    # milliseconds for the next tick
    delta = (@count + 1) * 100 - @elapsed
    @time.start
    @timer.start(delta)
  end
  
  def tick
    # update counter
    @count += 1
    elapsed = false
    
    # update clock state
    if @count % 10 == 0
      if @main <= 0
        # if we get here, there must be
        # a byoyomi, otherwise the timer would
        # be stopped
        @byoyomi.time -= 1
        if @byoyomi.time <= 0
          @byoyomi.periods -= 1
          @byoyomi.time = @byoyomi_time
          if @byoyomi.periods <= 0
            elapsed = true
          end
        end
      else
        @main -= 1
        if @main <= 0 and (not @byoyomi)
          elapsed = true
        end
      end
      
      if elapsed
        fire :elapsed
      elsif @main > 0
        fire :timer => { :main => @main }
      else
        fire :timer => { :byoyomi => @byoyomi.dup }
      end
    end
    
    if not elapsed
      # schedule next tick
      delta = (@count + 1) * 100 - @elapsed - @time.elapsed
      @timer.start(delta)
    end
  end
end