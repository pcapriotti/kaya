# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'test/unit'
require 'animation_field'
require 'toolkits/qt'
require 'rubygems'
require 'mocha'

class TestAnimationField < Test::Unit::TestCase
  def setup
    # remove connection with timer
    Qt::Timer.stubs(:every) {}
    
    # create a field with an accessor for actions
    @field = AnimationField.new(10)
    @field.metaclass_eval do
      attr_reader :actions
    end
  end
  
  def test_initialization
    assert_equal [], @field.actions
  end
  
  def test_tick_empty
    @field.tick(1.0)
    assert_equal [], @field.actions
  end
  
  def test_tick_exit
    action = mock("action") {|x| x.expects(:[]).with(1.0).returns(true) }
    @field.run action
    @field.tick(1.0)
    assert_equal [], @field.actions
  end
  
  def test_long_action
    @field.run create_action(10)
    10.times do |i|
      assert_equal 1, @field.actions.size
      @field.tick(i.to_f)
    end
    
    assert_equal [], @field.actions
  end
  
  def test_multiple_actions
    @field.run create_action(3)
    @field.run create_action(2)
    
    assert_equal 2, @field.actions.size
    @field.tick 1.0
    assert_equal 2, @field.actions.size
    @field.tick 2.0
    assert_equal 1, @field.actions.size
    @field.tick 3.0
    assert_equal [], @field.actions
  end
  
private
  def create_action(length)
    x = length
    lambda { x -= 1; x <= 0 }
  end
end
