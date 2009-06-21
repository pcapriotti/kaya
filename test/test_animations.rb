require 'test/unit'
require 'animations'
require 'board/point_converter'
require 'helpers/animation_test_helper'
require 'helpers/stubs'
require 'rubygems'

class FakeAnimator
  include Animations
  
  class Board
    include PointConverter
    def unit
      Qt::Point.new(50, 50)
    end
    
    def flipped?
      false
    end
    
    def raise(item)
    end
    
    def lower(item)
    end
  end
  
  attr_reader :board
  def initialize
    @board = Board.new
  end
end

class TestAnimations < Test::Unit::TestCase
  def setup
    @field = FakeAnimationField.new
    @c = FakeAnimator.new
  end
  
  def test_disappear
    item = GeneralMock.new
    @field.run @c.disappear(item)
    @field.run_test
    
    assert_equal [:opacity=, [1.0]], item.calls.shift
    assert_equal [:visible=, [true]], item.calls.shift
    
    old_op = 1.0
    while old_op > 0.0
      method, args = item.calls.shift
      break unless method == :opacity=
      assert_operator args.first, :<=, old_op
      old_op = args.first
    end
    
    assert_equal [:remove, []], item.calls.shift
    assert_equal [], item.calls
  end
  
  def test_appear
    item = GeneralMock.new
    @field.run @c.appear(item)
    @field.run_test
    
    assert_equal [:opacity=, [0.0]], item.calls.shift
    assert_equal [:visible=, [true]], item.calls.shift
    
    old_op = 0.0
    while true
      method, args = item.calls.shift
      break unless method == :opacity=
      assert_operator args.first, :>=, old_op
      old_op = args.first
    end
    
    assert_equal [], item.calls
  end
  
  def test_movement
    item = GeneralMock.new
    @field.run @c.movement(item, Point.new(3, 4), Point.new(5, 6), Path::Linear)
    @field.run_test
    
    old_p = nil
    while not item.calls.empty?
      method, args = item.calls.shift
      assert_equal :pos=, method
      p = args.first
      assert_not_nil p
      if old_p
        assert_operator old_p.x, :<=, p.x
        assert_operator old_p.y, :<=, p.y
        delta = p - old_p
        assert_in_delta 1.0, (delta.y.to_f / delta.x), 1e-5 if delta.x.abs >= 1e-5
      end
      old_p = p
    end
  end
end
