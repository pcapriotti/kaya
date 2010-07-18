# Copyright (c) 2010 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'test/unit'
require 'ostruct'
require 'require_bundle'
require_bundle 'clocks', 'clock_display'
require 'clock'

class TestClockDisplay < Test::Unit::TestCase
  class Display
    include ClockDisplay
    include Observer
    
    attr_reader :items
    
    def initialize(time_item)
      @items = { :time =>  OpenStruct.new }
    end
  end
  
  def setup
    @display = Display.new(@time_item)
    @display.clock = Clock.new(10, 0)
  end
  
  def test_simple
    @display.on_timer(4000)
    assert_equal "00:04", @display.items[:time].text
  end
  
  def test_large
    @display.on_timer(471381)
    assert_equal "07:52", @display.items[:time].text
  end
  
  def test_negative
    @display.on_timer(-3812)
    assert_equal "-00:03", @display.items[:time].text
  end
  
  def test_large_negative
    @display.on_timer(-471381)
    assert_equal "-07:51", @display.items[:time].text
  end
  
  def test_simple_negative
    @display.on_timer(-1000)
    assert_equal "-00:01", @display.items[:time].text
  end
  
  def test_small_negative
    @display.on_timer(-1)
    assert_equal "00:00", @display.items[:time].text
  end
  
  def test_zero
    @display.on_timer(0)
    assert_equal "00:00", @display.items[:time].text
  end
end
