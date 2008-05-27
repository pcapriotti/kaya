require 'test/unit'
require 'board/point_converter'

class TestPointConverter < Test::Unit::TestCase
  def setup
    @board = Object.new
    class << @board
      include PointConverter
      def unit
        Point.new(10, 10)
      end
    end
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
end
