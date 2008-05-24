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
end