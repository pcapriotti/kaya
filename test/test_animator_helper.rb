# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'test/unit'
require 'animator_helper'
require 'helpers/animation_test_helper'

class TestAnimatorHelper < Test::Unit::TestCase
  include AnimationAssertions
  
  def setup
    @items = { }
    board = FakeBoard.new(@items)
    @animator = Object.new
    @animator.metaclass_eval do
      include AnimatorHelper
      include StubbedAnimations
      define_method(:board) { board }
    end
  end
  
  def test_disappear
    @items[Point.new(3, 3)] = "white knight"
    anim = @animator.disappear_on!(Point.new(3, 3))
    assert_animation(:disappear, anim) do |args|
      assert_equal "white knight", args.first
    end
  end
  
  def test_appear
    anim = @animator.appear_on!(Point.new(3, 3), "black king")
    assert_animation(:appear, anim) do |args|
      assert_equal "black king", args.first
    end
  end
  
  def test_instant_disappear
    @items[Point.new(3, 3)] = "white knight"
    anim = @animator.disappear_on!(Point.new(3, 3), :instant => true)
    assert_animation(:disappear, anim)
  end
  
  def test_instant_appear
    anim = @animator.appear_on!(Point.new(3, 3), "black king", :instant => true)
    assert_animation(:appear, anim)
  end
  
  def test_move
    @items[Point.new(3, 3)] = "white knight"
    anim = @animator.move!(Point.new(3, 3), Point.new(5, 4), Path::Linear)
    assert_animation(:movement, anim) do |args|
      piece, src, dst = args
      assert_equal "white knight", piece
      assert_equal Point.new(3, 3), src
      assert_equal Point.new(5, 4), dst
    end
  end
  
  def test_morph
    @items[Point.new(3, 3)] = "white knight"
    anim = @animator.morph_on!(Point.new(3, 3), "black knight")
    assert_animation(:group, anim) do |args|
      appear, disappear = args.sort
      assert_animation(:appear, appear) do |args|
        assert_equal "black knight", args.first
      end
      assert_animation(:disappear, disappear) do |args|
        assert_equal "white knight", args.first
      end
    end
  end
end
