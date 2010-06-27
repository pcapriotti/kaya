# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'observer_utils'
require 'toolkit'

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
  def initialize(main, increment, byoyomi = nil, timer_class = Qt::Timer)
    @main = main
    @increment = increment
    if byoyomi
      @byoyomi = byoyomi.dup
      @byoyomi_time = @byoyomi.time
    end
    
    @timer = timer_class.new
    @timer.single_shot = true
    @timer.on(:timeout) { tick }
    @running = false
    @count = 0
    @elapsed = 0
    @time = Qt::Time.new
  end
  
  def stop
    if @running
      @elapsed += @time.elapsed
      @timer.stop
      
      @main += @increment
      
      @running = false
      fire :timer => { :main => @main }
    end
  end
  
  def start
    if not @running
      # milliseconds for the next tick
      delta = [0, (@count + 1) * 100 - @elapsed].max
      @time.start
      @timer.start(delta)
      @running = true
    end
  end
  
  def tick
    return unless @running
    
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
      else
        fire :timer => timer
      end
    end
    
    if not elapsed
      # schedule next tick
      delta = [0, (@count + 1) * 100 - @elapsed - @time.elapsed].max
      @timer.start(delta)
    end
  end
  
  def timer
    if @main > 0 or (not @byoyomi)
      { :main => @main }
    else
      { :byoyomi => @byoyomi.dup }
    end
  end
  
  def set_time(milliseconds)
    # update time
    @main = milliseconds / 1000

    # stop timer if we are below 0
    if @main <= 0
      @main = 0
      @timer.stop
      @running = false
    end
    
    # reset counter
    @count = 0
    @elapsed = milliseconds % 1000
    @time.restart
    
    fire :timer => timer
  end
  
  def running?
    @running
  end
end