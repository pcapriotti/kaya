require 'test/unit'
require 'games/all'

class TestShogiNotation < Test::Unit::TestCase
  def setup
    @game = Game.get(:shogi)
    @notation = @game.notation
  end

  def test_point_to_coord
    assert_equal '6b', 
      @notation.point_to_coord(Point.new(3, 1))
    assert_equal '5e',
      @notation.point_to_coord(Point.new(4, 4))
  end
  
  def test_point_from_coord
    assert_equal Point.new(3, 1),
      @notation.point_from_coord('6b')
    assert_equal Point.new(4, 4),
      @notation.point_from_coord('5e')
  end
  
  def test_notation1
    notation = @notation.from_s('+L-4e')
    assert_equal :promoted_lance, notation[:type]
    assert_nil notation[:src]
    assert ! notation[:drop]
    assert_equal Point.new(5, 4), notation[:dst]
  end
end
