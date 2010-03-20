# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'test/unit'
require 'clock'

class TestClock < Test::Unit::TestCase
  class FakeTimer
    def on(*args)
    end
    
    def single_shot=(val)
    end
    
    def start(ms)
    end
    
    def stop
    end
  end

  def test_main
    elapsed = false
    timer = nil
    
    # 2 seconds main time
    clock = Clock.new(2, 0, nil, FakeTimer)
    clock.on(:timer) {|timer|}
    clock.on(:elapsed) { elapsed = true }
    clock.start
    
    clock.tick
    assert ! elapsed
    assert_nil timer
    
    8.times { clock.tick }
    assert ! elapsed
    assert_nil timer
    
    clock.tick
    assert ! elapsed
    assert_equal({ :main => 1 }, timer)
    timer = nil
    
    9.times { clock.tick }
    assert ! elapsed
    assert_nil timer
    
    clock.tick
    assert elapsed
    assert_nil timer
  end
  
  def test_increment
    elapsed = false
    timer = nil
    
    # 10 seconds main time, 1 second increment
    clock = Clock.new(10, 1, nil, FakeTimer)
    clock.on(:timer) {|timer|}
    clock.on(:elapsed) { elapsed = true }
    clock.start
    
    80.times { clock.tick }
    assert ! elapsed
    assert_equal({:main => 2}, timer)
    timer = nil
    
    clock.stop
    assert ! elapsed
    assert_equal({:main => 3}, timer)
    clock.start
    
    15.times { clock.tick }
    assert ! elapsed
    assert_equal({:main => 2}, timer)
    timer = nil
    
    14.times { clock.tick }
    assert ! elapsed
    assert_equal({:main => 1}, timer)
    timer = nil
    
    clock.tick
    assert elapsed
    assert_nil timer
  end
  
  def test_byoyomi
    elapsed = false
    timer = nil
    
    # 10 seconds main time, 1 second byoyomi, 2 periods
    clock = Clock.new(10, 0, Clock::ByoYomi.new(1, 2), FakeTimer)
    clock.on(:timer) {|timer|}
    clock.on(:elapsed) { elapsed = true }
    clock.start
    
    80.times { clock.tick }
    assert ! elapsed
    assert_equal({:main => 2}, timer)

    25.times { clock.tick }
    assert ! elapsed
    assert_equal({:byoyomi => Clock::ByoYomi.new(1, 2)}, timer)
    
    10.times { clock.tick }
    assert ! elapsed
    assert_equal({:byoyomi => Clock::ByoYomi.new(1, 1) }, timer)
    
    5.times { clock.tick }
    assert elapsed
  end
end
