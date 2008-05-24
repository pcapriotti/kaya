require 'test/unit'
require 'point'

class TestPointRange < Test::Unit::TestCase
  def test_horizontal_range
    range = PointRange.new(Point.new(3, 1), Point.new(7, 1))
    assert range.parallel?
    assert_equal (3...7).map{|i| Point.new(i, 1) }, range.to_a
  end
  
  def test_vertical_range
    range = PointRange.new(Point.new(3, 1), Point.new(3, 6))
    assert range.parallel?
    assert_equal (1...6).map{|i| Point.new(3, i) }, range.to_a
  end
  
  def test_diagonal_range
    range = PointRange.new(Point.new(3, 1), Point.new(6, 4))
    assert range.diagonal?
    assert_equal [Point.new(3, 1),
                  Point.new(4, 2),
                  Point.new(5, 3)], range.to_a
  end
  
  def test_diagonal2_range
    range = PointRange.new(Point.new(7, 7), Point.new(0, 0))
    assert range.diagonal?
    assert_equal (1..7).map{|i| Point.new(i, i) }.reverse, range.to_a
  end
  
  def test_reverse_range
    range = PointRange.new(Point.new(6, 4), Point.new(0, 4))
    assert range.parallel?
    assert_equal (1..6).map{|i| Point.new(i, 4) }.reverse, range.to_a
  end
  
  def test_invalid_range
    range = PointRange.new(Point.new(0, 0), Point.new(4, 5))
    assert !range.valid?
    
    range = PointRange.new(Point.new(2, 3), Point.new(7, 4))
    assert !range.valid?
  end
end
