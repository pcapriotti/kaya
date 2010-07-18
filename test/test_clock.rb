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
    timer = nil
    
    # 2 seconds main time
    clock = Clock.new(2, 0, FakeTimer)
    clock.on(:timer) {|timer|}
    clock.start
    
    clock.tick
    assert_nil timer
    
    8.times { clock.tick }
    assert_nil timer
    
    clock.tick
    assert_equal(1000, timer)
    timer = nil
    
    9.times { clock.tick }
    assert_nil timer
    
    clock.tick
    assert_equal(0, timer)
  end
  
  def test_increment
    timer = nil
    
    # 10 seconds main time, 1 second increment
    clock = Clock.new(10, 1, FakeTimer)
    clock.on(:timer) {|timer|}
    clock.start
    
    80.times { clock.tick }
    assert_equal(2000, timer)
    timer = nil
    
    clock.stop
    assert_equal(3000, timer)
    clock.start
    
    15.times { clock.tick }
    assert_equal(2000, timer)
    timer = nil
    
    14.times { clock.tick }
    assert_equal(1000, timer)
    timer = nil
    
    clock.tick
    assert_equal(0, timer)
    timer = nil
    
    7.times { clock.tick }
    assert_nil timer
  end
  
  def test_resolution
    timer = nil
    
    clock = Clock.new(5, 0, FakeTimer)
    clock.on(:timer) {|timer|}
    clock.resolution = 100
    clock.start
    
    24.times { clock.tick }
    assert_equal(2600, timer)
    timer = nil
    
    clock.tick
    assert_equal(2500, timer)
    timer = nil
    
    30.times { clock.tick }
    assert_equal(-500, timer)
  end
  
  def test_invalid_resolution
    clock = Clock.new(10, 0, FakeTimer)
    assert_raise(RuntimeError) do
      clock.resolution = 50
    end
  end
end
