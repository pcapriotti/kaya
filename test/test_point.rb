require 'test/unit'
require 'point'

class TestPoint < Test::Unit::TestCase
  def test_getters
    p = Point.new(3, 4)
    assert_equal 3, p.x
    assert_equal 4, p.y
  end
  
  def test_equality
    assert_equal Point.new(4, 5), Point.new(4, 5)
    assert_not_equal Point.new(4, 5), Point.new(1, 2)
  end
  
  def test_sum
    assert_equal Point.new(7, 1), Point.new(3, 4) + Point.new(4, -3)
  end
  
  def test_difference
    assert_equal Point.new(4, 5), Point.new(10, 2) - Point.new(6, -3)
  end
  
  def test_scaling
    assert_equal Point.new(6, 2), Point.new(3, 1) * 2
    assert_equal Point.new(3, 9), Point.new(12, 36) / 4
  end
  
  def test_unit
    assert_equal Point.new(1, 1), Point.new(3, 3).unit
    assert_equal Point.new(1, 0), Point.new(4, 0).unit
    assert_equal Point.new(0, 0), Point.new(0, 0).unit
    assert_equal Point.new(-1, 1), Point.new(-5, 5).unit
  end
  
  def test_numeric_unit
    assert_equal -1, -5.unit
    assert_equal 0, 0.unit
    assert_equal 1, 83.unit
    assert_equal -1, -0.34.unit
  end
end