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
  STEP = 100
  
  attr_reader :resolution
  attr_accessor :debug
  
  def initialize(main, increment, timer_class = Qt::Timer)
    @rem = main
    @rem_last = @rem
    update_displayed
    
    @increment = increment
    @resolution = 1000
    @timer = timer_class.new
    @timer.single_shot = true
    @timer.on(:timeout) { tick }
    @running = false
    @time = Qt::Time.new
    
  end
  
  def stop
    if @running
      @timer.stop
      
      update_remaining
      @rem += @increment
      @displayed += @increment
      
      @running = false
      fire :timer => timer
    end
  end
  
  def start
    if not @running
      @rem_last = @rem
      @time.start

      @timer.start(delta)
      @running = true
    end
  end
  
  def timer
    @displayed
  end
  
  def tick
    return unless @running
    
    update_remaining
    @displayed -= STEP
    
    if @displayed % @resolution == 0
      fire :timer => timer
    end
    
    @timer.start(delta)
  end
  
  def set_time(rem)
    @rem = rem
    update_displayed
    
    # always stop the timer when forcing a time
    @timer.stop
    @running = false
    
    fire :timer => timer
  end
  
  def running?
    @running
  end
  
  def resolution=(value)
    if value <= 0 || (value % STEP != 0)
      raise "Invalid resolution"
    end
    @resolution = value
  end
  
  private
  
  def update_remaining
    @rem = @rem_last - @time.elapsed
  end
  
  def update_displayed
    @displayed = @rem + STEP - 1 - (@rem - 1) % STEP
  end
  
  def delta
    [0, STEP - @displayed + @rem].max
  end
end
