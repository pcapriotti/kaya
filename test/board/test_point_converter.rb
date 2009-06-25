require 'test/unit'
require 'board/point_converter'
require 'games/all'

class TestPointConverter < Test::Unit::TestCase
  class FakeBoard
    include PointConverter
    
    def initialize
      @flipped = false
      @game = Struct.new(:size).new(Point.new(8, 8))
    end
    
    def unit
      Point.new(10, 10)
    end
    
    def flipped?
      @flipped
    end
    
    def flip!
      @flipped = !flipped?
    end
  end
  
  def setup
    @board = FakeBoard.new
  end
  
  def test_to_logical
    assert_equal Point.new(0, 0), @board.to_logical(Point.new(0, 0))
    assert_equal Point.new(5, 4), @board.to_logical(Point.new(50, 40))
    assert_equal Point.new(0, -1), @board.to_logical(Point.new(9, -3))
    assert_equal Point.new(-2, 3), @board.to_logical(Point.new(-16, 31))
  end
  
  def test_to_real
    assert_equal Point.new(20, 80), @board.to_real(Point.new(2, 8))
    assert_equal Point.new(0, 0), @board.to_real(Point.new(0, 0))
    assert_equal Point.new(20, -40), @board.to_real(Point.new(2, -4))
  end
  
  def test_to_logical_flipped
    @board.flip!
    assert_equal Point.new(7, 7), @board.to_logical(Point.new(0, 0))
    assert_equal Point.new(2, 3), @board.to_logical(Point.new(50, 40))
    assert_equal Point.new(7, 8), @board.to_logical(Point.new(9, -3))
    assert_equal Point.new(9, 4), @board.to_logical(Point.new(-16, 31))  
  end
  
  def test_to_real_flipped
    @board.flip!
    assert_equal Point.new(50, 80), @board.to_real(Point.new(2, -1))
    assert_equal Point.new(70, 0), @board.to_real(Point.new(0, 7))
    assert_equal Point.new(50, -40), @board.to_real(Point.new(2, 11))
  end
end
