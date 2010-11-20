# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'observer_utils'
require 'toolkit'

#
# A clock keeps track of game time and sends regular updates to a graphical
# clock component whenever the displayed time needs to change.
#
# The clock is based on the idea of _displayed_ time, which is the value in
# milliseconds that is displayed to the user on a clock with a specified
# _resolution_. For example, if the remaining time is 13561 milliseconds, and
# the resolution is 1 second, the displayed time is 14000.
#
# In general, the displayed time is the smallest multiple of the resolution
# which is greater or equal to the actual time.
#
# The other important concept is the _step_. This is currently set to the
# constant 100, and represents the frequency with which the internal timer is
# fired.
#
# The resolution can be set while the clock is running, but only to a multiple
# of the step.
#
class Clock
  include Observable
  STEP = 100
  
  attr_reader :resolution
  attr_accessor :debug
  
  #
  # Create a clock object. Times are expressed in milliseconds.
  # The timer_class argument can be used to provide a different factory for
  # the internal timer (the default is Qt::Timer).
  #
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
  
  #
  # Stop the timer.
  #
  # The clock keeps track of the portion of step elapsed since the last tick,
  # and will compensate when resuming.
  #
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
  
  #
  # Start or resume the timer.
  #
  def start
    if not @running
      @rem_last = @rem
      @time.start

      @timer.start(delta)
      @running = true
    end
  end
  
  #
  # The current displayed time.
  #
  def timer
    @displayed
  end
  
  #
  # The main internal method, called every STEP milliseconds to update the
  # internal state and keep track of elapsed time.
  #
  # Fire timer signal when the displayed time is a multiple of resolution.
  #
  def tick
    return unless @running
    
    update_remaining
    @displayed -= STEP
    
    if @displayed % @resolution == 0
      fire :timer => timer
    end
    
    @timer.start(delta)
  end
  
  #
  # Forcibly set a time for this clock.
  #
  # As a side effect, this method causes the timer to stop.
  #
  def set_time(rem)
    @rem = rem
    update_displayed
    
    # always stop the timer when forcing a time
    @timer.stop
    @running = false
    
    fire :timer => timer
  end
  
  #
  # Whether the clock is running
  #
  def running?
    @running
  end
  
  #
  # Set resolution in milliseconds.
  #
  # The value must be a multiple of STEP.
  #
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
